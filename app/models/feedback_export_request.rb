require "csv"
require "plek"

class FeedbackExportRequest < ApplicationRecord
  validates :notification_email, :filters, presence: true

  serialize :filters, Hash

  before_validation on: :create do
    filters[:to] ||= Date.today
    filters[:path_prefixes] = path_filters
    generate_filename! if filename.nil?
  end

  def generate_filename!
    parts = [
      "feedex",
      filters[:from].nil? ? "0000-00-00" : filters[:from].to_date.iso8601,
      filters[:to].nil? ? Date.today.iso8601 : filters[:to].to_date.iso8601,
    ]

    if path_filters
      parts += segments_of_first_path + and_x_number_of_other_paths
    end
    parts << filters[:organisation_slug] if filters[:organisation_slug].present?
    parts << filters[:document_type] if filters[:document_type].present?
    self.filename = "#{parts.join("_")}.csv"
  end

  def path_filters
    filters[:path_prefixes] = [filters[:path_prefix]] if filters[:path_prefix]
    filters.delete(:path_prefix)
    @path_filters ||= filters[:path_prefixes]
  end

  def segments_of_first_path
    path_filters.first.split("/").reject(&:blank?)
  end

  def and_x_number_of_other_paths
    count = path_filters.count - 1
    base_path = path_filters.first == "/" ? %w[base_path] : []
    if count >= 2
      base_path + ["and", count, "other", "paths"]
    elsif count == 1
      base_path + %w[and another path]
    else
      []
    end
  end

  def results
    AnonymousContact.
      for_query_parameters(filters).
      most_recent_last
  end

  def generate_csv
    CSV.generate do |csv|
      csv << FeedbackCsvRowPresenter::HEADER_ROW
      results.find_each { |row| csv << FeedbackCsvRowPresenter.new(row).to_a }
    end
  end

  def url
    Plek.find("support", external: true) + "/anonymous_feedback/export_requests/#{id}"
  end
end
