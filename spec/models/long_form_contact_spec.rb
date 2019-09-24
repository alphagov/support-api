require "rails_helper"

describe LongFormContact do
  it { should validate_presence_of(:details) }
  it { should validate_length_of(:user_specified_url).is_at_most(2048) }
  it { should validate_length_of(:details).is_at_most(2**16) }
end
