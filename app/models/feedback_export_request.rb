class FeedbackExportRequest < ActiveRecord::Base
  validates :notification_email, :filter_to, :path_prefix, presence: true

  before_validation on: :create do
    self.filter_to ||= Date.today
    self.path_prefix ||= "/"
    generate_filename! if filename.nil?
  end

  def generate_filename!
    parts = [
      "feedex",
      filter_from.nil? ? "0000-00-00" : filter_from.to_date.iso8601,
      filter_to.nil? ? Date.today.iso8601 : filter_to.to_date.iso8601,
    ]
    parts += self.path_prefix.split("/").reject(&:blank?)
    self.filename = "#{parts.join("_")}.csv"
  end

  def results
    AnonymousContact.
      for_query_parameters(path_prefix: path_prefix, from: filter_from, to: filter_to).
      most_recent_last
  end
end
