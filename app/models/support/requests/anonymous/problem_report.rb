require 'support/requests/anonymous/anonymous_contact'

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
      end
    end
  end
end
