require "rails_helper"
require "field_which_may_contain_personal_information"

describe ContentImprovementFeedback, type: :model do
  def new_feedback(options = {})
    build :content_improvement_feedback, options
  end

  def create_feedback(options = {})
    create :content_improvement_feedback, options
  end

  it { should allow_value("something is missing").for(:description) }
  it { should validate_length_of(:description).is_at_most(2**16) }
  it { should validate_length_of(:description).is_at_least(1) }

  it "validates the personal_information_status field" do
    expect(new_feedback(personal_information_status: nil)).to be_valid
    expect(new_feedback(personal_information_status: "suspected")).to be_valid
    expect(new_feedback(personal_information_status: "absent")).to be_valid

    expect(new_feedback(personal_information_status: "abcde")).to_not be_valid
  end

  it "notices when an email is present the description" do
    expect(create_feedback(description: "contact me at name@domain.com please").personal_information_status).to eq("suspected")
  end

  it "notices when a national insurance number is present in the description" do
    expect(create_feedback(description: "my NI number is QQ 12 34 56 A thanks").personal_information_status).to eq("suspected")
  end
end
