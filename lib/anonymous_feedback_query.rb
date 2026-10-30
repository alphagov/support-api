require "date_parser"
require "uri"

class AnonymousFeedbackQuery
  PATH_PARAMS = %w[paths paths[] path].freeze

  def initialize(query_string)
    @params = URI.decode_www_form(query_string).reject { |_name, value| value.empty? }
  end

  def options
    from, to = %w[from to].map { |name| DateParser.parse(value_of(name)) }
    from, to = [from, to].sort if from && to

    {
      path_prefixes: values_of(PATH_PARAMS).uniq,
      organisation_slug: value_of("organisation"),
      document_type: value_of("document_type"),
      from:,
      to:,
    }
  end

  def page
    value_of("page").to_i
  end

private

  def value_of(name)
    @params.assoc(name)&.last
  end

  def values_of(names)
    @params.select { |name, _value| names.include?(name) }.map(&:last)
  end
end
