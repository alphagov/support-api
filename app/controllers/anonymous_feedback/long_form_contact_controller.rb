module AnonymousFeedback
  class LongFormContactController < ApplicationController
    def create
      request = LongFormContact.new(long_form_contact_params)

      if request.valid?
        LongFormContactWorker.perform_async(long_form_contact_params)
        head :accepted
      else
        render json: { "errors" => request.errors.to_a }, status: 422
      end
    end

    private
    def long_form_contact_params
      params.require(:long_form_contact).permit(
        :path, :referrer, :javascript_enabled, :user_agent, :details, :user_specified_url
      ).to_h
    end
  end
end
