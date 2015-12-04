class Organisation < ActiveRecord::Base
  has_and_belongs_to_many :content_items
  has_many :problem_reports, through: :content_items
  has_many :anonymous_contacts, through: :content_items

  validates :slug, presence: true
  validates :web_url, presence: true
  validates :title, presence: true
  validates :content_id, presence: true

  def self.for_path(path)
    SupportApi.organisation_lookup.organisations_for(path)
  end

  def as_json(options)
    super(only: [:slug, :web_url, :title, :acronym, :govuk_status])
  end
end
