class Organisation < ApplicationRecord
  has_and_belongs_to_many :content_items
  has_many :problem_reports, through: :content_items
  has_many :anonymous_contacts, through: :content_items

  validates :slug, presence: true
  validates :web_url, presence: true
  validates :title, presence: true
  validates :content_id, presence: true

  def as_json(_options)
    super(only: %i[slug web_url title acronym govuk_status])
  end
end
