Rails.application.routes.draw do
  scope "anonymous-feedback", module: "anonymous_feedback" do
    resources "service-feedback",
              only: :create,
              format: false,
              controller: "service_feedback",
              as: "service_feedback"

    resources "long-form-contacts",
              only: :create,
              format: false,
              controller: "long_form_contact",
              as: "long_form_contact"
  end

  get "/healthcheck", :to => proc { [200, {}, ["OK"]] }
end
