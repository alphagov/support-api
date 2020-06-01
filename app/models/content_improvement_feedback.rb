require "field_which_may_contain_personal_information"

class ContentImprovementFeedback < ApplicationRecord
  before_save :detect_personal_information
  validates :description, length: { within: 1..65_536 }
  validates :personal_information_status, inclusion: { in: %w[suspected absent], allow_nil: true }

private

  def detect_personal_information
    self.personal_information_status = personal_info_present? ? "suspected" : "absent"
  end

  def personal_info_present?
    FieldWhichMayContainPersonalInformation.new(description).include_personal_info?
  end
end
