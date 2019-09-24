class DateParser
  def self.parse(date)
    return nil if date.nil?

    Date.parse(date)
  rescue ArgumentError
    nil
  end
end
