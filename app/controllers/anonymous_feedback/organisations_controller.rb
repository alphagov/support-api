module AnonymousFeedback
  class OrganisationsController < ApplicationController
    def index
      @organisations = Organisation.order(:slug)
      render
    end
  end
end
