module AnonymousFeedback
  class OrganisationsController < ApplicationController
    def show
      ordering = if %w[path last_7_days last_30_days last_90_days].include? params[:ordering]
                   params[:ordering]
                 else
                   "last_7_days"
                 end
      organisation = Organisation.find_by(slug: params[:slug])

      if organisation.nil?
        head :not_found
        return
      end

      anonymous_feedback_counts = AnonymousContact.summary(
        ordering,
        relation: AnonymousContact.for_organisation_slug(organisation.slug),
      )

      render json: {
        slug: organisation.slug,
        title: organisation.title,
        anonymous_feedback_counts:,
      }
    end
  end
end
