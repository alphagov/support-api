class ContentItem < ActiveRecord::Base
  has_and_belongs_to_many :organisations
  has_many :problem_reports, class_name: "ProblemReport"
  validates :path, presence: true

  before_create :fetch_organisations, unless: ->(content_item) { content_item.organisations.present? }

  private
  def fetch_organisations
    self.organisations = Organisation.for_path(path)
  end
end
