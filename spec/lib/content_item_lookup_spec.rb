require "rails_helper"
require "content_item_lookup"
require "plek"
require "gds_api/test_helpers/content_store"

describe ContentItemLookup do
  include GdsApi::TestHelpers::ContentStore

  let(:content_store) { GdsApi::ContentStore.new(Plek.find("content-store")) }

  let(:subject) { ContentItemLookup.new(content_store: content_store) }

  let(:hmrc_org_content_store_response) {
    {
      content_id: "6667cce2-e809-4e21-ae09-cb0bdc1ddda3",
      base_path: "/government/organisations/hm-revenue-customs",
      document_type: "placeholder_organisation",
      title: "HM Revenue & Customs",
    }
  }

  let(:contact_ukvi_content_store_response) {
    {
      content_id: "04148522-b0c1-4137-b687-5f3c3bdd561a",
      base_path: "/uk-visas-and-immigration",
      title: "UK Visas and Immigration",
      document_type: "organisation",
    }
  }

  let(:check_uk_visa_content_store_response) {
    contact_ukvi_content_store_response.merge(
      base_path: "/check-uk-visa",
    )
  }

  let(:contact_ukvi_content_store_response) {
    {
      base_path: "/contact-ukvi",
      document_type: "placeholder",
    }
  }

  let(:dfid_content_store_response) {
    {
      base_path: "/government/world/organisations/dfid-bangladesh",
      document_type: "placeholder",
    }
  }

  let(:hmrc_contact_page_content_store_response) {
    {
      base_path: "/government/organisations/hm-revenue-customs/contact/vat-enquiries",
      document_type: "placeholder",
    }
  }

  let(:civil_service_fast_stream_org_response) {
    {
      content_id: "e1dfcc51-9bda-444c-94f2-d5e4c4b3cd0b",
      title: "Civil Service Fast Stream",
      base_path: "/organisations/civil-service-fast-stream",
    }
  }

  let(:case_study_content_store_response) {
    {
      base_path: "/government/case-studies/gender-identity",
      document_type: "case_study",
      links: {
        lead_organisations: [civil_service_fast_stream_org_response],
      },
    }
  }

  let(:hmrc) {
    Organisation.create_with(
      content_id: "6667cce2-e809-4e21-ae09-cb0bdc1ddda3",
      slug: "hm-revenue-customs",
      web_url: "http://www.dev.gov.uk/government/organisations/hm-revenue-customs",
      title: "HM Revenue & Customs",
    ).find_or_create_by(slug: "hm-revenue-customs")
  }

  let(:ukvi) {
    Organisation.create_with(
      content_id: "04148522-b0c1-4137-b687-5f3c3bdd561a",
      slug: "uk-visas-and-immigration",
      web_url: "https://www.gov.uk/government/organisations/uk-visas-and-immigration",
      title: "UK Visas and Immigration",
    ).find_or_create_by(slug: "uk-visas-and-immigration")
  }

  let!(:gds) { create(:gds) }
  let!(:dfid) { create(:dfid) }
  let!(:hmrc) { create(:hmrc) }

  it "fetches content items from the Content Store" do
    content_store_has_item("/government/case-studies/gender-identity", case_study_content_store_response)

    content_item = subject.lookup("/government/case-studies/gender-identity")

    expect(content_item.path).to eq("/government/case-studies/gender-identity")
    expect(content_item.document_type).to eq("case_study")
    expect(content_item.organisations.first).to match(hash_including(slug: "civil-service-fast-stream"))
  end

  it "fetches an organisation page from the Content Store" do
    content_store_has_item("/government/organisations/hm-revenue-customs", hmrc_org_content_store_response)

    content_item = subject.lookup("/government/organisations/hm-revenue-customs")

    expect(content_item.path).to eq("/government/organisations/hm-revenue-customs")
    expect(content_item.organisations.first).to match(hash_including(hmrc.attributes.slice(:slug, :web_url)))
  end

  context "when the path cannot be found in the Content Store" do
    it "guesses the 'parent' path by removing one path segment (the default case)" do
      content_store_does_not_have_item("/contact-ukvi/overview")
      content_store_has_item("/contact-ukvi", contact_ukvi_content_store_response)

      content_item = subject.lookup("/contact-ukvi/overview")

      expect(content_item.path).to eq("/contact-ukvi")
      expect(content_item.organisations.first).to match(hash_including(ukvi.attributes.slice(:slug, :web_url)))
    end

    it "guesses the 'parent' path for smart-answer paths" do
      content_store_does_not_have_item("/check-uk-visa/y/australia")
      content_store_has_item("/check-uk-visa", check_uk_visa_content_store_response)

      content_item = subject.lookup("/check-uk-visa/y/australia")

      expect(content_item.path).to eq("/check-uk-visa")
      expect(content_item.organisations.first).to match(hash_including(ukvi.attributes.slice(:slug, :web_url)))
    end

    it "guesses the organisation for certain world organisation content" do
      content_store_has_item("/government/world/organisations/dfid-bangladesh", dfid_content_store_response)

      content_item = subject.lookup("/government/world/organisations/dfid-bangladesh")

      expect(content_item.path).to eq("/government/world/organisations/dfid-bangladesh")
      expect(content_item.organisations.first).to match(hash_including(dfid.attributes.slice(:slug, :web_url)))
    end

    it "guesses HMRC as the org for HMRC contact pages" do
      content_store_has_item("/government/organisations/hm-revenue-customs/contact/vat-enquiries", hmrc_contact_page_content_store_response)

      content_item = subject.lookup("/government/organisations/hm-revenue-customs/contact/vat-enquiries")

      expect(content_item.path).to eq("/government/organisations/hm-revenue-customs/contact/vat-enquiries")
    expect(content_item.organisations.first).to match(hash_including(hmrc.attributes.slice(:slug, :web_url)))
    end

    it "returns a completely new content item with GDS as the org (so the problem report is assigned to at least one org)" do
      content_store_does_not_have_item("/help")

      content_item = subject.lookup("/help")

      expect(content_item.path).to eq("/help")
      expect(content_item.organisations.first).to match(hash_including(gds.attributes.slice(:slug, :web_url)))
    end
  end
end
