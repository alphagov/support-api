require 'user_agent_parser'

class FeedbackCsvRowPresenter
  attr_reader :row

  HEADER_ROW = ["creation date", "path or service name", "feedback", "service satisfaction rating",
                "browser name", "browser version", "browser platform", "user agent", "referrer", "type"]

  def initialize(row)
    @row = row
  end

  def to_a
    [
      row.created_at.strftime("%F %T"),
      row.type == "service-feedback" ? row.slug : row.path,
      details_text,
      row.type == "service-feedback" ? row.service_satisfaction_rating.to_s : "",
      parsed_user_agent.family,
      parsed_user_agent.version.to_s,
      parsed_user_agent.os.family,
      row.user_agent,
      row.referrer,
      row.type
    ]
  end

  def parsed_user_agent
    @parsed_user_agent ||= UserAgentParser.parse row.user_agent
  end

  def details_text
    case row.type
    when "problem-report"
      "#{row.what_doing}\n#{row.what_wrong}"
    when "service-feedback"
      row.details
    when "long-form-contact"
      row.details
    end
  end
end
