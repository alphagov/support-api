class ApplicationMailer < Mail::Notify::Mailer
  default from: "inside-government@digital.cabinet-office.gov.uk"
  layout false


  def template_id
    @template_id ||= ENV.fetch("GOVUK_NOTIFY_TEMPLATE_ID", "fake-test-template-id")
  end
end
