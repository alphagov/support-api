class FieldWhichMayContainPersonalInformation
  NATIONAL_INSURANCE_NUMBER_PATTERN = /[a-zA-Z]{2}[0-9]{6}[a-zA-Z]{1}/.freeze
  EMAIL_ADDRESS_PATTERN = /@/.freeze

  def initialize(text)
    @text = text
  end

  def include_personal_info?
    include_email_address? || include_national_insurance_number?
  end

private

  def include_email_address?
    (not @text.nil?) && @text =~(EMAIL_ADDRESS_PATTERN)
  end

  def include_national_insurance_number?
    (not @text.nil?) && @text.gsub(/\s/, "") =~(NATIONAL_INSURANCE_NUMBER_PATTERN)
  end
end
