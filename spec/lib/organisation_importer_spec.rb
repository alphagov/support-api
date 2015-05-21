require 'rails_helper'
require 'organisation_importer'

describe OrganisationImporter do
  before do
    organisations = organisations_api_response.map {|o|
      OpenStruct.new(
        title: o[:name],
        details: OpenStruct.new(slug: o[:slug],
                                govuk_status: "live",
                                abbreviation: o[:abbreviation]),
        web_url: "https://gov.uk/government/organisations/#{o[:slug]}"
      )
    }
    stub_subsequent_pages = double(with_subsequent_pages: organisations)
    allow_any_instance_of(GdsApi::Organisations).to receive(:organisations)
      .and_return(stub_subsequent_pages)
  end

  let(:organisations_api_response) do
    [{
      slug: "ministry-of-magic",
      name: "Ministry of Magic",
      abbreviation: "MOM"
    },{
      slug: "ministry-of-fun",
      name: "Ministry of Fun and Games",
      abbreviation: "MOFG"
    },{
      slug: "ministry-of-unicorns",
      name: "Ministry of Unicorns",
      abbreviation: "MOU"
    }]
  end

  before do
    FactoryGirl.create(:organisation, title: "Ministry of Magic",
                                      slug: "ministry-of-magic",
                                      acronym: "MOM")
    FactoryGirl.create(:organisation, title: "Ministry of Fun",
                                      slug: "ministry-of-fun",
                                      acronym: "MOF")
    described_class.new.run
  end

  it "doesn't update an existing organisation if it hasn't changed" do
    mom = Organisation.find_by(slug: "ministry-of-magic")
    expect(mom.title).to eq("Ministry of Magic")
    expect(mom.acronym).to eq("MOM")
  end

  it "update an existing organisation if it has changed" do
    mof = Organisation.find_by(slug: "ministry-of-fun")
    expect(mof.title).to eq("Ministry of Fun and Games")
    expect(mof.acronym).to eq("MOFG")
  end

  it "creates a new organisation if it doesn't already exist" do
    mou = Organisation.find_by(slug: "ministry-of-unicorns")
    expect(mou.title).to eq("Ministry of Unicorns")
    expect(mou.acronym).to eq("MOU")
  end
end
