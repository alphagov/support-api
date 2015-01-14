require 'spec_helper'
require 'content_api/enhanced_content_api'
require 'plek'
require 'gds_api/test_helpers/content_api'
require 'gds_api/content_api'

module ContentAPI
  describe EnhancedContentAPI do
    include GdsApi::TestHelpers::ContentApi

    let(:content_api) { GdsApi::ContentApi.new(Plek.find('contentapi')) }
    subject(:api) { EnhancedContentAPI.new(content_api) }

    context "mapping multi-page content to slugs" do
      it "maps mainstream guide sections to the guide root" do
        mappings = {
          [ "/contact-ukvi", "/contact-ukvi/overview" ] => "/contact-ukvi",
          [ "/tax-disc"] => "/tax-disc",
          [ "/check-uk-visa/y", "/check-uk-visa" ] => "/check-uk-visa",
          [
            "/government/organisations/hm-revenue-customs",
            "/government/organisations/hm-revenue-customs/contact/corporation-tax-enquiries",
            "/government/organisations/hm-revenue-customs/services-information",
          ] => "/government/organisations/hm-revenue-customs",
          [
            "/government/publications/govuk-proposition",
            "/government/publications/govuk-proposition/govuk-proposition",
          ] => "/government/publications/govuk-proposition",
          [ "/contact" ] => "/contact",
          [ "/contact/govuk" ] => "/contact/govuk",
          [ "/search" ] => "/search",
          [ "/browse/driving" ] => "/browse/driving",
          [ "/browse/driving/blue-badge-parking" ] => "/browse/driving/blue-badge-parking",
        }

        mappings.each do |source_paths, content_item_path|
          source_paths.each { |source_path| expect(api.content_item_path(source_path)).to eq(content_item_path) }
        end
      end
    end

    context "organisation lookup" do
      let(:default_content_api_response) {
        {
          tags: [
            {
              id: "https://www.gov.uk/api/tags/organisation/uk-visas-and-immigration.json",
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

      let(:gds_org_info) {
        {
          slug: "government-digital-service",
          web_url: "https://www.gov.uk/government/organisations/government-digital-service",
          title: "Government Digital Service",
        }
      }

      context "(mainstream content)" do
        it "fetches the organisations" do
          content_api_has_an_artefact("/contact-ukvi", default_content_api_response)

          expect(api.organisations_for("/contact-ukvi/overview")).to eq([
            slug: "uk-visas-and-immigration",
            web_url: "https://www.gov.uk/government/organisations/uk-visas-and-immigration",
            title: "UK Visas and Immigration",
          ])
        end
      end

      context "(Depts & Policy content)" do
        it "fetches the organisations" do
          content_api_has_an_artefact(
            "/government/publications/customer-service-commitments-uk-visas-and-immigration",
            default_content_api_response
          )

          expect(api.organisations_for("/government/publications/customer-service-commitments-uk-visas-and-immigration")).to eq([
            slug: "uk-visas-and-immigration",
            web_url: "https://www.gov.uk/government/organisations/uk-visas-and-immigration",
            title: "UK Visas and Immigration",
          ])
        end
      end

      context "(GDS-owned pages)" do
        it "should have GDS as the owning org" do
          [ "/help", "/help/beta", "/contact", "/contact/govuk", "/search", "/browse", "/browse/driving" ].each do |gds_owned_path|
            expect(api.organisations_for(gds_owned_path)).to eq([gds_org_info])
          end
        end
      end

      context "(organisation pages)" do
        let(:hmrc_info) {
          {
            slug: "hm-revenue-customs",
            web_url: "https://www.gov.uk/government/organisations/hm-revenue-customs",
            title: "HM Revenue & Customs",
          }
        }

        let(:hmrc_org_content_api_response) {
          {
            id: "https://www.gov.uk/api/organisations/hm-revenue-customs",
            title: "HM Revenue & Customs",
            web_url: "https://www.gov.uk/government/organisations/hm-revenue-customs",
            details: {
              slug: "hm-revenue-customs",
            },
          }
        }

        it "should be attributed to that org" do
          content_api_has_an_artefact("/organisations/hm-revenue-customs", hmrc_org_content_api_response)

          [
            "/government/organisations/hm-revenue-customs",
            "/government/organisations/hm-revenue-customs/contact/corporation-tax-enquiries",
            "/government/organisations/hm-revenue-customs/services-information",
          ].each do |hmrc_path|
            expect(api.organisations_for(hmrc_path)).to eq([hmrc_info])
          end
        end
      end
    end
  end
end
