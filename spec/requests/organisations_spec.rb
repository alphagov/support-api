require 'rails_helper'

describe "Organisations that have feedback left on 'their' content" do
  let(:hmrc_info) {
    {
      "slug" => "hm-revenue-customs",
      "title" => "HM Revenue & Customs",
      "web_url" => "https://www.gov.uk/hmrc",
    }
  }

  let(:ukvi_info) {
    {
      "slug" => "uk-visas-and-immigration",
      "title" => "UK Visas & Immigration",
      "web_url" => "https://www.gov.uk/ukvi",
    }
  }

  let!(:ukvi) { create(:organisation, ukvi_info) }
  let!(:hmrc) { create(:organisation, hmrc_info) }

  it "can be retrieved (so that it's possible to not deal with orgs that have no feedback)" do
    get_json "/anonymous-feedback/organisations"

    expect(json_response.size).to eq(2)
    expect(json_response[0]).to eq(hmrc_info)
    expect(json_response[1]).to eq(ukvi_info)
  end
end
