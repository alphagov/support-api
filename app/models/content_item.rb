class ContentItem < ActiveRecord::Base
  has_and_belongs_to_many :organisations
  validates :path, presence: true

  before_create :fetch_organisations

  private
  def fetch_organisations
    self.organisations = Organisation.for_path(path)
  end
end
