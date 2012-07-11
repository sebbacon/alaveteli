class AddRefactoredUkSpecificRegexps < ActiveRecord::Migration
  def self.up
    CensorRule.create(:text => '\*\*\*+\nPolly Tucker.*',
                      :replacement => '',
                      :regexp => true,
                      :last_edit_editor => 'system',
                      :last_edit_comment => 'Refactored from remove_privacy_sensitive_things!')

    CensorRule.create(:text => 'Andy 079.*',
                      :replacement => 'Andy [mobile number]',
                      :regexp => true,
                      :last_edit_editor => 'system',
                      :last_edit_comment => 'Refactored from remove_privacy_sensitive_things!')

    CensorRule.create(:text => '(Complaints and Corporate Affairs Officer)\s+Westminster Primary Care Trust.+',
                      :replacement => 'Andy [mobile number]',
                      :regexp => true,
                      :last_edit_editor => 'system',
                      :last_edit_comment => 'Refactored from remove_privacy_sensitive_things!')

    home_office = PublicBody.find_by_url_name('home_office')
    if home_office.present?
        CensorRule.create(:text => 'Your password:-\s+[^\s]+',
                          :replacement => '[password]',
                          :public_body => home_office,
                          :regexp => true,
                          :last_edit_editor => 'system',
                          :last_edit_comment => 'Refactored from remove_privacy_sensitive_things!')
        CensorRule.create(:text => 'Password=[^\s]+',
                          :replacement => '[password]',
                          :public_body => home_office,
                          :regexp => true,
                          :last_edit_editor => 'system',
                          :last_edit_comment => 'Refactored from remove_privacy_sensitive_things!')
    end
  end

  def self.down
    CensorRule.find_all_by_last_edit_comment_and_regexp('Refactored from remove_privacy_sensitive_things!',
                                                        true).each(&:destroy)
  end
end
