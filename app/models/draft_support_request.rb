class DraftSupportRequest < ApplicationRecord
  validates :support_app_reference, presence: true, uniqueness: true
end
