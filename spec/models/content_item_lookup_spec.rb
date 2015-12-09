require 'rails_helper'
require 'content_item_lookup'
require 'plek'
require 'gds_api/test_helpers/content_api'
require 'gds_api/test_helpers/content_store'

describe ContentItemLookup do
  include GdsApi::TestHelpers::ContentApi
  include GdsApi::TestHelpers::ContentStore

  let(:content_api) { GdsApi::ContentApi.new(Plek.find('contentapi')) }
  let(:content_store) { GdsApi::ContentStore.new(Plek.find('content-store')) }

  let(:subject) { ContentItemLookup.new(content_api: content_api, content_store: content_store) }

  let(:hmrc_org_content_store_response) {
    {
      content_id: "6667cce2-e809-4e21-ae09-cb0bdc1ddda3",
      base_path: "/government/organisations/hm-revenue-customs",
      format: "placeholder_organisation",
      title: "HM Revenue & Customs",
    }
  }

  let(:contact_ukvi_content_api_response) {
    {
      web_url: 'https://www.gov.uk/contact-ukvi',
      tags: [
        {
          id: "https://www.gov.uk/api/tags/organisation/uk-visas-and-immigration.json",
          content_id: "04148522-b0c1-4137-b687-5f3c3bdd561a",
          slug: "uk-visas-and-immigration",
          web_url: "https://www.gov.uk/government/organisations/uk-visas-and-immigration",
          title: "UK Visas and Immigration",
          details: {
            type: "organisation"
          },
        },
      ]
    }
  }

  let(:check_uk_visa_content_api_response) {
    contact_ukvi_content_api_response.tap { |response|
      response["web_url"] = "https://www.gov.uk/check-uk-visa"
    }
  }

  let(:contact_ukvi_content_store_response) {
    {
      base_path: '/contact-ukvi',
      format: "placeholder",
    }
  }

  let(:dfid_content_store_response) {
    {
      base_path: '/government/world/organisations/dfid-bangladesh',
      format: "placeholder",
    }
  }

  let(:case_study_content_store_response) {
    {
      base_path: '/government/case-studies/gender-identity',
      format: 'case_study',
      links: {
        lead_organisations: [
          {
            content_id: "e1dfcc51-9bda-444c-94f2-d5e4c4b3cd0b",
            title: "Civil Service Fast Stream",
            base_path: "/organisations/civil-service-fast-stream",
          },
        ]
      }
    }
  }

  let(:hmrc) {
    Organisation.find_by!(
      content_id: "6667cce2-e809-4e21-ae09-cb0bdc1ddda3",
      slug: "hm-revenue-customs",
      web_url: "http://www.dev.gov.uk/government/organisations/hm-revenue-customs",
      title: "HM Revenue & Customs",
    )
  }

  let(:ukvi) {
    Organisation.find_by!(
      content_id: "04148522-b0c1-4137-b687-5f3c3bdd561a",
      slug: "uk-visas-and-immigration",
      web_url: "https://www.gov.uk/government/organisations/uk-visas-and-immigration",
      title: "UK Visas and Immigration",
    )
  }

  let!(:gds) { create(:gds) }
  let!(:dfid) { create(:dfid) }

  it "fetches content items from the Content Store" do
    content_store_has_item('/government/case-studies/gender-identity', case_study_content_store_response)
    content_api_does_not_have_an_artefact('government/case-studies/gender-identity')

    content_item = subject.lookup('/government/case-studies/gender-identity')

    expect(content_item.path).to eq('/government/case-studies/gender-identity')
    expect(content_item.organisations).to eq([ Organisation.find_by!(slug: 'civil-service-fast-stream') ])
  end

  it "fetches an organisation page from the Content Store" do
    content_store_has_item('/government/organisations/hm-revenue-customs', hmrc_org_content_store_response)
    content_api_does_not_have_an_artefact('government/organisations/hm-revenue-customs')

    content_item = subject.lookup('/government/organisations/hm-revenue-customs')

    expect(content_item.path).to eq('/government/organisations/hm-revenue-customs')
    expect(content_item.organisations).to eq([hmrc])
  end

  it "fetches artefacts from the Content API" do
    content_store_does_not_have_item('/contact-ukvi')
    content_api_has_an_artefact("contact-ukvi", contact_ukvi_content_api_response)

    content_item = subject.lookup('/contact-ukvi')

    expect(content_item.path).to eq("/contact-ukvi")
    expect(content_item.organisations).to eq([ukvi])
  end

  it "takes the orgs from Content API if the item is in both Content API and Content Store, and Content Store returns no orgs" do
    content_store_has_item("/contact-ukvi", contact_ukvi_content_store_response)
    content_api_has_an_artefact("contact-ukvi", contact_ukvi_content_api_response)

    content_item = subject.lookup('/contact-ukvi')

    expect(content_item.path).to eq("/contact-ukvi")
    expect(content_item.organisations).to eq([ukvi])
  end

  context "when the path cannot be found in either Content API or Content Store" do
    it "guesses the 'parent' path by removing one path segment (the default case)" do
      content_store_does_not_have_item("/contact-ukvi/overview")
      content_api_does_not_have_an_artefact('contact-ukvi/overview')
      content_store_does_not_have_item('/contact-ukvi')
      content_api_has_an_artefact("contact-ukvi", contact_ukvi_content_api_response)

      content_item = subject.lookup('/contact-ukvi/overview')

      expect(content_item.path).to eq("/contact-ukvi")
      expect(content_item.organisations).to eq([ukvi])
    end

    it "guesses the 'parent' path for smart-answer paths" do
      content_store_does_not_have_item("/check-uk-visa/y/australia")
      content_api_does_not_have_an_artefact('check-uk-visa/y/australia')
      content_store_does_not_have_item('/check-uk-visa')
      content_api_has_an_artefact("check-uk-visa", check_uk_visa_content_api_response)

      content_item = subject.lookup('/check-uk-visa/y/australia')

      expect(content_item.path).to eq("/check-uk-visa")
      expect(content_item.organisations).to eq([ukvi])
    end

    it "guesses the organisation for certain world organisation content" do
      content_store_has_item("/government/world/organisations/dfid-bangladesh", dfid_content_store_response)
      content_api_has_an_artefact('government/world/organisations/dfid-bangladesh', {
        web_url: 'https://www.gov.uk/government/world/organisations/dfid-bangladesh',
      })

      content_item = subject.lookup('/government/world/organisations/dfid-bangladesh')

      expect(content_item.path).to eq('/government/world/organisations/dfid-bangladesh')
      expect(content_item.organisations).to eq([dfid])
    end

    it "returns a completely new content item with GDS as the org (so the problem report is assigned to at least one org)" do
      content_store_does_not_have_item("/help")
      content_api_does_not_have_an_artefact('help')

      content_item = subject.lookup('/help')

      expect(content_item.path).to eq("/help")
      expect(content_item.organisations).to eq([gds])
    end
  end
end
