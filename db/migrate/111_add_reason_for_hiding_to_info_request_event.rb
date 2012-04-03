require 'digest/sha1'

class AddReasonForHidingToInfoRequestEvent < ActiveRecord::Migration
    def self.up
        add_column :info_request_events, :reason_for_hiding, :text, :null => true
    end
    def self.down
        remove_column :info_request_events, :reason_for_hiding
    end
end
