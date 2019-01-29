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

    resources "export-requests",
              only: [:create, :show],
              format: false,
              controller: "export_requests",
              as: "export_request"

    resources "global-export-requests",
              only: [:create],
              format: false,
              controller: "global_export_requests",
              as: "global_export_request"

    resources "content_improvement",
              only: [:create],
              format: false,
              controller: "content_improvement",
              as: "content_improvement"

    get '/problem-reports/:date/totals',
        constraints: { date: /\d{4}-\d{2}-\d{2}/ },
        to: 'problem_reports#totals'

    get '/problem-reports',
        to: 'problem_reports#index'

    put '/problem-reports/mark-reviewed-for-spam',
         format: false,
         to: 'problem_reports#mark_reviewed_for_spam'

    get '/organisations/:slug', to: 'organisations#show'
    get '/document-types', to: 'document_types#index', format: false
    get '/document-types/:document_type', to: 'document_types#show', format: false
  end

  resources 'page-improvements',
            controller: 'page_improvements',
            as: 'page_improvement',
            only: [:create]

  resources :organisations,
            only: [:index, :show],
            format: false,
            param: :slug

  get '/feedback-by-day/:date', to: 'feedback_by_day#index', format: false

  get "/healthcheck", :to => proc { [200, {}, ["OK"]] }
end
