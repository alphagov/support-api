class Organisation < ActiveRecord::Base
  has_and_belongs_to_many :content_items

  validates :slug, presence: true
  validates :web_url, presence: true
  validates :title, presence: true
end
