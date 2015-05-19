Rails.application.routes.draw do
  resources "anonymous-feedback",
            only: :index,
            format: false,
            controller: "anonymous_feedback",
            as: "anonymous_feedback"

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

    resources "problem-reports",
              only: :create,
              format: false,
              controller: "problem_reports",
              as: "problem_report"

    get '/problem-reports/:date/totals',
        constraints: { date: /\d{4}-\d{2}-\d{2}/ },
        to: 'problem_reports#totals'

    get '/problem-reports/:period',
        constraints: { period: /\d{4}-\d{2}(-\d{2})?/ },
        to: 'problem_reports#index'

    resources 'organisations',
        only: :index,
        format: false
  end

  get "/healthcheck", :to => proc { [200, {}, ["OK"]] }
end
