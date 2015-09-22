require 'rails_helper'
require 'gds_api/test_helpers/content_api'

describe ContentItemEnrichmentWorker do
  include GdsApi::TestHelpers::ContentApi

  subject { ContentItemEnrichmentWorker.new }

  context "for a problem report about a piece of content we can't determine the organisation for" do
    let(:problem_report) { create(:problem_report, path: "/unknown-org-page") }

    before do
      content_api_does_not_have_an_artefact("unknown-org-page")
      subject.perform(problem_report.id)
      problem_report.reload
    end

    it "assigns the problem_report to GDS" do
      expect(problem_report.content_item.path).to eq("/unknown-org-page")
      expect(problem_report.content_item.organisations.first["title"]).to eq("Government Digital Service")
    end
  end

  context "for a problem report about a piece of content we know the organisation of" do
    let(:hmrc) { Organisation.where(slug: 'hm-revenue-customs').first }
    let(:vat_rates_content_api_response) {
      api_response = artefact_for_slug("vat-rates").tap do |hash|
        hash["tags"] = [
          {
            slug: "hm-revenue-customs",
            web_url: "https://www.gov.uk/government/organisations/hm-revenue-customs",
            title: "HM Revenue & Customs",
            details: {
              type: "organisation",
            }
          }
        ]
      end
    }

    let(:problem_report) { create(:problem_report, path: "/vat-rates") }

    before do
      content_api_has_an_artefact("vat-rates", vat_rates_content_api_response)
      subject.perform(problem_report.id)
      problem_report.reload
    end

    it "assigns the problem report to the organisation" do
      expect(problem_report.content_item.path).to eq("/vat-rates")
      expect(problem_report.content_item.organisations).to eq([hmrc])
    end
  end

  context "for a problem report about a piece of content whose organisation has changed" do
    let(:hmrc) { Organisation.where(slug: 'hm-revenue-customs').first }
    let(:aaib) { Organisation.where(slug: 'air-accidents-investigation-branch').first }
    let(:vat_rates_content_api_response) {
      api_response = artefact_for_slug("vat-rates").tap do |hash|
        hash["tags"] = [
          {
            slug: "hm-revenue-customs",
            web_url: "https://www.gov.uk/government/organisations/hm-revenue-customs",
            title: "HM Revenue & Customs",
            details: {
              type: "organisation",
            }
          }
        ]
      end
    }
    let(:vat_rates_content_api_response_new) {
      api_response = artefact_for_slug("vat-rates").tap do |hash|
        hash["tags"] = [
          {
            slug: "air-accidents-investigation-branch",
            web_url: "https://www.gov.uk/government/organisations/air-accidents-investigation-branch",
            title: "aaib",
            details: {
              type: "organisation",
            }
          }
        ]
      end
    }

    let(:problem_report) { create(:problem_report, path: "/vat-rates") }

    before do
      content_api_has_an_artefact("vat-rates", vat_rates_content_api_response)
      subject.perform(problem_report.id)
      problem_report.reload
    end

    it "assigns the problem report to the new organisation" do
      expect(problem_report.content_item.organisations).to eq([hmrc])
      content_api_has_an_artefact("vat-rates", vat_rates_content_api_response_new)
      subject.perform(problem_report.id)
      problem_report.reload
      expect(problem_report.content_item.organisations).to eq([aaib])
    end
  end
end
