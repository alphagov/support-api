require "simplecov"
require "simplecov-rcov"
SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
SimpleCov.start "rails"

RSpec.configure do |config|
  config.after(:each) do
    Timecop.return
  end
end
