class PageImprovementsController < ApplicationController
  def create
    page_improvement = PageImprovement.new(page_improvement_attributes)

    if page_improvement.valid?
      GDS_ZENDESK_CLIENT.ticket.create!(page_improvement.zendesk_ticket_attributes)

      render json: { status: 'success' }, status: 201
    else
      render json: { status: 'error', errors: page_improvement.errors }, status: 422
    end
  end

private
  def page_improvement_attributes
    params.slice(:description, :path, :name, :email, :user_agent)
  end
end
