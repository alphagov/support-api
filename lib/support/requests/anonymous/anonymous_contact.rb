require 'support/requests/anonymous/field_which_may_contain_personal_information'
require 'support/requests/anonymous/duplicate_detector'

module Support
  module Requests
    module Anonymous
      class AnonymousContact < ActiveRecord::Base
        before_save :detect_personal_information
        before_save :set_path_from_url

        validates :referrer, url: true, length: { maximum: 2048 }, allow_nil: true
        validates :url,      url: true, length: { maximum: 2048 }, allow_nil: true
        validates :path,     url: true, length: { maximum: 2048 }, allow_nil: true
        validates :user_agent, length: { maximum: 2048 }
        validates :details, length: { maximum: 2 ** 16 }
        validates_inclusion_of :javascript_enabled, in: [ true, false ]
        validates_inclusion_of :personal_information_status, in: [ "suspected", "absent" ], allow_nil: true
        validates_inclusion_of :is_actionable, in: [ true, false ]
        validates_presence_of :reason_why_not_actionable, unless: "is_actionable"

        scope :only_actionable, -> { where(is_actionable: true) }
        default_scope { only_actionable }

        def self.deduplicate_contacts_created_between(interval)
          contacts = where(created_at: interval).order("created_at asc")
          deduplication_attribute_names = attribute_names - ["id", "created_at", "updated_at"]
          duplicate_detector = DuplicateDetector.new(deduplication_attribute_names)
          contacts.each do |contact|
            if duplicate_detector.duplicate?(contact)
              contact.mark_as_duplicate
              contact.save!
            end
          end
        end

        def mark_as_duplicate
          self.is_actionable = false
          self.reason_why_not_actionable = "duplicate"
          self
        end

      private
        def detect_personal_information
          self.personal_information_status ||= personal_info_present? ? "suspected" : "absent"
        end

        def personal_info_present?
          free_text_fields = [ self.details, self.what_wrong, self.what_doing ]
          free_text_fields.any? { |text| FieldWhichMayContainPersonalInformation.new(text).include_personal_info? }
        end

        def set_path_from_url
          self.path = URI.parse(url).path unless url.blank?
        end
      end
    end
  end
end
