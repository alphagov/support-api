class OrganisationsController < ApplicationController
  def index
    organisations = Organisation.order(:slug)
    render json: organisations
  end

  def show
    organisation = Organisation.find_by(slug: params[:slug])
    if organisation
      render json: organisation
    else
      head :not_found
    end
  end
end
