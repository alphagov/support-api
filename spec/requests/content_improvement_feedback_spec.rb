require "rails_helper"

describe "Content Improvement Feedback" do
  let(:common_headers) { { "CONTENT_TYPE" => "application/json", "HTTP_ACCEPT" => "application/json" } }
  context "successful post" do
    before do
      post "/anonymous-feedback/content_improvement",
           params: { description: "this thing is missing" }.to_json,
           headers: common_headers
    end

    it "responds successfully" do
      expect(response.status).to eq(202)
    end

    it "creates a ContentImprovementFeedback with correct description" do
      expect(ContentImprovementFeedback.all.first).to have_attributes(
        description: "this thing is missing",
        reviewed: false,
        marked_as_spam: false,
        personal_information_status: "absent",
      )
    end
  end

  context "when the message contains personal information" do
    before do
      post "/anonymous-feedback/content_improvement",
           params: { description: "contact me at user@domain.com" }.to_json,
           headers: common_headers
    end

    it "responds successfully" do
      expect(response.status).to eq(202)
    end

    it "marks the feedback personal_information_status as `suspected`" do
      expect(ContentImprovementFeedback.all.first).to have_attributes(
        description: "contact me at user@domain.com",
        reviewed: false,
        marked_as_spam: false,
        personal_information_status: "suspected",
      )
    end
  end

  context "when the description is not supplied" do
    it "returns an appropriate error" do
      post "/anonymous-feedback/content_improvement",
           params: {}.to_json,
           headers: common_headers

      expect(response.status).to eq(422)
      expect(JSON.parse(response.body)["errors"]).to include(
        "Description is too short (minimum is 1 character)",
      )
    end
  end

  context "when the description is blank" do
    it "returns an appropriate error" do
      post "/anonymous-feedback/content_improvement",
           params: { description: "" }.to_json,
           headers: common_headers

      expect(response.status).to eq(422)
      expect(JSON.parse(response.body)["errors"]).to include(
        "Description is too short (minimum is 1 character)",
      )
    end
  end
end
