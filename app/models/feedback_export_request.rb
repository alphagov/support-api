require 'csv'
require 'plek'

class FeedbackExportRequest < ActiveRecord::Base
  validates :notification_email, :filters, presence: true

  serialize :filters, Hash

  before_validation on: :create do
    filters[:to] ||= Date.today
    generate_filename! if filename.nil?
  end

  def generate_filename!
    parts = [
      "feedex",
      filters[:from].nil? ? "0000-00-00" : filters[:from].to_date.iso8601,
      filters[:to].nil? ? Date.today.iso8601 : filters[:to].to_date.iso8601,
    ]
    parts += filters[:path_prefix].split("/").reject(&:blank?) if filters[:path_prefix].present?
    parts << filters[:organisation_slug] if filters[:organisation_slug].present?
    self.filename = "#{parts.join("_")}.csv"
  end

  def results
    AnonymousContact.
      for_query_parameters(filters).
      most_recent_last
  end

  def generate_csv(io)
    csv = CSV.new(io)
    csv << FeedbackCsvRowPresenter::HEADER_ROW
    results.find_each do |row|
      csv << FeedbackCsvRowPresenter.new(row).to_a
    end
    io
  end

  def url
    Plek.find('support') + "/anonymous_feedback/export_requests/#{id}"
  end
end
