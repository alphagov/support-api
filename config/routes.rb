Rails.application.routes.draw do
  scope "anonymous-feedback", module: "anonymous_feedback" do
    resources "service-feedback",
              only: :create,
              format: false,
              controller: "service_feedback",
              as: "service_feedback"
  end

  get "/healthcheck", :to => proc { [200, {}, ["OK"]] }
end
