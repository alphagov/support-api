require 'support/requests/anonymous/field_which_may_contain_personal_information'

module Support
  module Requests
    module Anonymous
      class AnonymousContact < ActiveRecord::Base
        before_save :detect_personal_information
        before_save :set_path_from_url

        validates :referrer, url: true, length: { maximum: 2048 }, allow_nil: true
        validates :url,      url: true, length: { maximum: 2048 }, allow_nil: true
        validates :path,     url: true, length: { maximum: 2048 }, allow_nil: true
        validates :details, length: { maximum: 2 ** 16 }
        validates_inclusion_of :javascript_enabled, in: [ true, false ]
        validates_inclusion_of :personal_information_status, in: [ "suspected", "absent" ], allow_nil: true
        validates_inclusion_of :is_actionable, in: [ true, false ]
        validates_presence_of :reason_why_not_actionable, unless: "is_actionable"

        private
        def detect_personal_information
          self.personal_information_status ||= personal_info_present? ? "suspected" : "absent"
        end

        def personal_info_present?
          free_text_fields = [ self.details, self.what_wrong, self.what_doing ]
          free_text_fields.any? { |text| FieldWhichMayContainPersonalInformation.new(text).include_personal_info? }
        end

        def set_path_from_url
          self.path = URI.parse(url).path unless url.nil?
        end
      end
    end
  end
end
