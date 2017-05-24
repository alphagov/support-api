module AnonymousFeedback
  class OrganisationsController < ApplicationController
    def show
      if %w(path last_7_days last_30_days last_90_days).include? params[:ordering]
        ordering = params[:ordering]
      else
        ordering = "last_7_days"
      end
      organisation = Organisation.find_by(slug: params[:slug])

      if organisation.nil?
        head :not_found
        return
      end

      anonymous_feedback_counts = ContentItem.
        for_organisation(organisation).
        summary(ordering)

      render json: {
        slug: organisation.slug,
        title: organisation.title,
        anonymous_feedback_counts: anonymous_feedback_counts,
      }
    end
  end
end
