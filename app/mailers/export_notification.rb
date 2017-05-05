class ExportNotification < ApplicationMailer
  def notification_email(email, url)
    @url = url
    mail(to: email, subject: "[GOV.UK Feedback Explorer] Your feedback export is ready")
  end
end
