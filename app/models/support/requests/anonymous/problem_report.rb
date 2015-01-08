require 'support/requests/anonymous/anonymous_contact'
require 'content_api/enhanced_content_api'

module Support
  module Requests
    module Anonymous
      class ProblemReport < AnonymousContact
        validates :what_doing, length: { maximum: 2 ** 16 }
        validates :what_wrong, length: { maximum: 2 ** 16 }

        belongs_to :content_item

        scope :totals_for, ->(date) {
          where(created_at: date.beginning_of_day..date.end_of_day).
            select("path, count(path) as total").
            group(:path).
            order("total desc")
        }

        def content_item_path
          SupportApi::enhanced_content_api.content_item_path(path)
        end
      end
    end
  end
end
