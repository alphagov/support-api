class GlobalExportRequest
  include ActiveModel::Model

  attr_accessor :notification_email, :from_date, :to_date, :exclude_spam

  validates :notification_email, presence: true
  validates :from_date, presence: true
  validates :to_date, presence: true
  validates :exclude_spam, presence: true
end
