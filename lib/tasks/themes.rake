
namespace :themes do

    def plugin_dir
        File.join(Rails.root,"vendor","plugins")
    end

    def theme_dir(theme_name)
        File.join(plugin_dir, theme_name)
    end

    def install_theme_using_git(name, uri, verbose=false, options={})
        mkdir_p(install_path = theme_dir(name))
        Dir.chdir install_path do
            init_cmd = "git init"
            init_cmd += " -q" if options[:quiet] and not verbose
            puts init_cmd if verbose
            system(init_cmd)
            base_cmd = "git pull --depth 1 #{uri}"
            # Is there a tag for this version of Alaveteli?
            usage_tag = "use-with-alaveteli-#{ALAVETELI_VERSION}"
            # Query the remote repository passing flags for tags and
            # a non-zero return code on failure to find the tag
            if system("git ls-remote --exit-code --tags #{uri} #{usage_tag}")
                # If we got a tag, pull that instead of HEAD
                puts "Using tag #{usage_tag}" if verbose
                base_cmd += " refs/tags/#{usage_tag}"
            else
                puts "No specific tag for this version: using HEAD" if verbose
            end
            base_cmd += " -q" if options[:quiet] and not verbose
            puts base_cmd if verbose
            if system(base_cmd)
                puts "removing: .git .gitignore" if verbose
                rm_rf %w(.git .gitignore)
            else
                rm_rf install_path
                raise "#{base_cmd} failed! Stopping."
            end
        end
    end

    def uninstall(theme_name, verbose=false)
        dir = theme_dir(theme_name)
        if File.directory?(dir)
            run_hook(theme_name, 'uninstall', verbose)
            puts "Removing '#{dir}'" if verbose
            rm_r dir
        else
            puts "Plugin doesn't exist: #{dir}"
        end
    end

    def run_hook(theme_name, hook_name, verbose=false)
        hook_file = File.join(theme_dir(theme_name), "#{hook_name}.rb")
        if File.exist? hook_file
            puts "Running #{hook_name} hook for #{theme_name}" if verbose
            load hook_file
        end
    end

    def installed?(theme_name)
        File.directory?(theme_dir(theme_name))
    end

    def install_theme(theme_url, verbose, deprecated=false)
        deprecation_string = deprecated ? " using deprecated THEME_URL" : ""
        theme_name = File.basename(theme_url, '.git')
        puts "Installing theme #{theme_name}#{deprecation_string} from #{theme_url}"
        uninstall(theme_name, verbose) if installed?(theme_name)
        install_theme_using_git(theme_name, theme_url, verbose)
        run_hook(theme_name, 'install', verbose)
        run_hook(theme_name, 'post_install', verbose)
    end

    desc "Install themes specified in the config file's THEME_URLS"
    task :install => :environment do
        verbose = false
        theme_urls = MySociety::Config.get("THEME_URLS", [])
        theme_urls.each{ |theme_url| install_theme(theme_url, verbose) }
        theme_url = MySociety::Config.get("THEME_URL", "")
        if ! theme_url.blank?
            # Old version of the above, for backwards compatibility
            install_theme(theme_url, verbose, deprecated=true)
        end
    end
end