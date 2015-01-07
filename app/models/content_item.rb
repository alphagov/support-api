class ContentItem < ActiveRecord::Base
  validates :path, presence: true
end
