class PageImprovementsController < ApplicationController
  def create
    page_improvement = PageImprovement.new(page_improvement_attributes)

    if page_improvement.valid?
      GDS_ZENDESK_CLIENT.ticket.create!(page_improvement.zendesk_ticket_attributes)

      render json: { status: "success" }, status: :created
    else
      render json: { status: "error", errors: page_improvement.errors }, status: :unprocessable_entity
    end
  end

private

  def page_improvement_attributes
    params.slice(:description, :url, :name, :email, :user_agent)
  end
end
