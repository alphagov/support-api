require "rails_helper"

RSpec.describe DraftSupportRequest, type: :model do
  context "when there is no support app reference" do
    it "is not valid" do
      draft_support_request = build(:draft_support_request, :no_reference)

      expect(draft_support_request.valid?).to eq false
      expect(draft_support_request.errors.first.full_message).to eq "Support app reference can't be blank"
    end
  end

  it "does not allow duplicate reference values" do
    create(:draft_support_request)

    draft_support_request = build(:draft_support_request)

    expect(draft_support_request.valid?).to eq false
    expect(draft_support_request.errors.first.full_message).to eq "Support app reference has already been taken"
  end
end
