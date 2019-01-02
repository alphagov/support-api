require 'rails_helper'

describe "Organisations that have feedback left on 'their' content" do
  let(:hmrc_info) {
    {
      "slug" => "hm-revenue-customs",
      "title" => "HM Revenue & Customs",
      "web_url" => "https://www.gov.uk/hmrc",
      "acronym" => "HMRC",
      "govuk_status" => "live"
    }
  }

  let(:ukvi_info) {
    {
      "slug" => "uk-visas-and-immigration",
      "title" => "UK Visas & Immigration",
      "web_url" => "https://www.gov.uk/ukvi",
      "acronym" => "UKVI",
      "govuk_status" => "live"
    }
  }

  let!(:ukvi) { create(:organisation, ukvi_info) }
  let!(:hmrc) { create(:organisation, hmrc_info) }

  before do
    create(:content_item, organisations: [ ukvi ], path: "/abc",
      anonymous_contacts: [
        create(:anonymous_contact, created_at: 5.days.ago),
        create(:anonymous_contact, created_at: 15.days.ago),
      ]
    )

    create(:content_item, organisations: [ ukvi ], path: "/def",
      anonymous_contacts: [
        create(:anonymous_contact, created_at: 70.days.ago),
        create(:anonymous_contact, created_at: 75.days.ago),
        create(:anonymous_contact, created_at: 80.days.ago),
      ]
    )
  end

  it "can be retrieved (so that it's possible to not deal with orgs that have no feedback)" do
    get_json "/organisations"

    expect(json_response).to contain_exactly(hmrc_info, ukvi_info)
  end

  it "provides feedback counts per org, sorted by the 7 day column by default" do
    get_json "/anonymous-feedback/organisations/uk-visas-and-immigration"

    expect(json_response).to eq(
      "title" => "UK Visas & Immigration",
      "slug" => "uk-visas-and-immigration",
      "anonymous_feedback_counts" => [
        { "path" => "/abc", "last_7_days" => 1, "last_30_days" => 2, "last_90_days" => 2 },
        { "path" => "/def", "last_7_days" => 0, "last_30_days" => 0, "last_90_days" => 3 },
      ]
    )
  end

  it "provides feedback counts per org, sorted by the 90 day column if requested" do
    get_json "/anonymous-feedback/organisations/uk-visas-and-immigration?ordering=last_90_days"

    expect(json_response).to eq(
      "title" => "UK Visas & Immigration",
      "slug" => "uk-visas-and-immigration",
      "anonymous_feedback_counts" => [
        { "path" => "/def", "last_7_days" => 0, "last_30_days" => 0, "last_90_days" => 3 },
        { "path" => "/abc", "last_7_days" => 1, "last_30_days" => 2, "last_90_days" => 2 },
      ]
    )
  end

  context "when the user is not authenticated" do
    around do |example|
      ClimateControl.modify(GDS_SSO_MOCK_INVALID: "1") { example.run }
    end

    it "returns an unauthorized response" do
      get "/organisations"
      expect(response).to be_unauthorized
    end
  end
end
