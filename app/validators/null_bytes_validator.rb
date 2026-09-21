class NullBytesValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.nil?

    if options[:allowed] == false && value.match?(/\x00/)
      record.errors.add(attribute, options[:message] || "must not contain null bytes")
    end
  end
end
