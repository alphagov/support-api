require 'user_agent_parser'

class FeedbackCsvRowPresenter
  attr_reader :row

  HEADER_ROW = [
    "creation date", "path or service name", "feedback", "service satisfaction rating",
    "browser name", "browser version", "browser platform", "user agent", "referrer", "type",
    "primary organisation", "all organisations"
  ].freeze

  def self.parser
    Thread.current[:user_agent_parser] ||= UserAgentParser::Parser.new
  end

  def initialize(row)
    @row = row
  end

  def to_a
    [
      row.created_at.strftime("%F %T"),
      row.type == "service-feedback" ? row.slug : row.path,
      details_text,
      service_satisfaction_rating,
      parsed_user_agent.family,
      parsed_user_agent.version.to_s,
      "#{parsed_user_agent.os.family} #{parsed_user_agent.os.version}",
      row.user_agent,
      row.referrer,
      row.type,
      primary_organisation,
      all_organisations
    ]
  end

  def parsed_user_agent
    @parsed_user_agent ||= self.class.parser.parse row.user_agent
  end

  def details_text
    case row.type
    when "problem-report"
      "#{row.what_doing}\n#{row.what_wrong}"
    when "service-feedback"
      row.details
    when "long-form-contact"
      row.details
    when "aggregated-service-feedback"
      "Rating of #{row.service_satisfaction_rating}: #{row.details}"
    end
  end

  def service_satisfaction_rating
    if row.type =~ /^(aggregated-)?service-feedback$/
      row.service_satisfaction_rating.to_s
    else
      ""
    end
  end

  def primary_organisation
    row.organisations.first.try(:title) || ""
  end

  def all_organisations
    row.organisations.map(&:title).join("|")
  end
end
