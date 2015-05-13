require 'csv'
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

        scope :with_known_page_owner, -> { where.not(page_owner: nil) }

        def content_item_path
          SupportApi::enhanced_content_api.content_item_path(path)
        end

        def type
          "problem-report"
        end

        def url
          path ? Plek.new.website_root + path : nil
        end

        def as_json(options)
          super(only: [ :type, :url, :id, :created_at, :what_wrong, :what_doing, :referrer, :user_agent ])
        end

        def self.to_csv(reports)
          CSV.generate do |csv|
            csv << ProblemReportPresenter.header_row
            reports.each do |report|
              csv << ProblemReportPresenter.new(report).to_a
            end
          end
        end
      end
    end
  end
end
