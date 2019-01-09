require 'rails_helper'

describe "Global export requests" do
  context "when the user is not authenticated" do
    around do |example|
      ClimateControl.modify(GDS_SSO_MOCK_INVALID: "1") { example.run }
    end

    it "returns an unauthorized response" do
      post '/anonymous-feedback/global-export-requests', params: {}.to_json
      expect(response).to be_unauthorized
    end
  end
end
