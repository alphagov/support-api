require 'support/requests/anonymous/anonymous_contact'

module Support
  module Requests
    module Anonymous
      class ServiceFeedback < AnonymousContact
        validates_presence_of :slug, :service_satisfaction_rating
        validates :details, length: { maximum: 2 ** 16 }
        validates_inclusion_of :service_satisfaction_rating, in: (1..5).to_a

        def type
          "service-feedback"
        end

        def as_json(options = {})
          attributes_to_serialise = [
            :type, :path, :id, :created_at, :referrer, :user_agent, :slug,
            :service_satisfaction_rating, :details,
          ]
          super({
            only: attributes_to_serialise,
            methods: :url,
          }.merge(options))
        end

        def self.transaction_slugs
          uniq.pluck(:slug).sort
        end

        def self.aggregates_by_rating
          zero_defaults = Hash[*(1..5).map {|n| [n, 0] }.flatten]
          select("service_satisfaction_rating, count(*) as cnt").
            group(:service_satisfaction_rating).
            inject(zero_defaults) { |memo, result| memo[result[:service_satisfaction_rating]] = result[:cnt]; memo }
        end

        def self.with_comments_count
          where("details IS NOT NULL").count
        end
      end
    end
  end
end
