class GlobalExportNotification < ActionMailer::Base
  default from: "inside-government@digital.cabinet-office.gov.uk"
  layout false

  def notification_email(notification_email, filename, csv_contents)
    attachments[filename] = csv_contents

    mail(
      to: notification_email,
      subject: "[GOV.UK Feedback Explorer] Your global export is attached"
    )
  end
end
