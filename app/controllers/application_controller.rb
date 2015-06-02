class ApplicationController < ActionController::API
  def parse_date(date)
    return nil if date.nil?
    parsed_date = Date.parse(date)
  rescue ArgumentError
    return nil
  end
end
