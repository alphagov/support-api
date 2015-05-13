module AnonymousFeedback
  class OrganisationsController < ApplicationController
    def index
      organisations = Organisation.order(:slug)
      render json: organisations
    end
  end
end
