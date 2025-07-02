class ContentItem < ApplicationRecord
  has_and_belongs_to_many :organisations
  has_many :problem_reports, class_name: "ProblemReport"
  has_many :anonymous_contacts
  validates :path, presence: true

  scope :for_organisation,
        lambda { |organisation|
          joins(:organisations)
          .where(organisations: { id: organisation.id })
        }

  scope :for_document_type,
        lambda { |document_type|
          where(document_type:)
        }

  def fetch_organisations
    self.organisations = Organisation.for_path(path)
    save!
  end

  def self.all_document_types
    distinct.pluck(:document_type).reject { |d| d == "" }.compact
  end
end
