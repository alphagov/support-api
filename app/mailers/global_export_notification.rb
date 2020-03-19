class GlobalExportNotification < ApplicationMailer
  def notification_email(notification_email, url)
    @url = url
    view_mail(
      template_id,
      to: notification_email,
      subject: "[GOV.UK Feedback Explorer] Your global export is ready",
    )
  end
end
