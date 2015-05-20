module AnonymousFeedback
  class OrganisationsController < ApplicationController
    def index
      organisations = Organisation.order(:slug)
      render json: organisations
    end

    def show
      organisation = Organisation.find_by(slug: params[:slug])
      anonymous_feedback_counts = ContentItem.
        for_organisation(organisation).
        summary("last_7_days")

      render json: {
        slug: organisation.slug,
        title: organisation.title,
        anonymous_feedback_counts: anonymous_feedback_counts,
      }
    end
  end
end
