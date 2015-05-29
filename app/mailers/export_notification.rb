class ExportNotification < ActionMailer::Base
  default from: "inside-government@digital.cabinet-office.gov.uk"

  layout false

  def notification_email(email, url)
    @url = url
    mail(to: email, subject: "[GOV.UK Feedback Explorer] Your feedback export is ready")
  end
end
