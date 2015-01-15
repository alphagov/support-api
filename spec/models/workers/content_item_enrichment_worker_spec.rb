require 'rails_helper'
require 'gds_api/test_helpers/content_api'

describe ContentItemEnrichmentWorker do
  include GdsApi::TestHelpers::ContentApi

  subject { ContentItemEnrichmentWorker.new }

  context "for a problem report that relates to a non-existent piece of content" do
    let(:problem_report) { create(:problem_report, path: "/non-existent-page") }

    before do
      content_api_does_not_have_an_artefact("non-existent-page")
      subject.perform(problem_report.id)
      problem_report.reload
    end

    it "creates a content item for the problem report, but no orgs" do
      expect(problem_report.content_item.path).to eq("/non-existent-page")
      expect(problem_report.content_item.organisations).to be_empty
    end
  end

  context "for a problem report that relates to a piece of mainstream content" do
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

    it "creates a content item for the problem report, but no orgs" do
      expect(problem_report.content_item.path).to eq("/vat-rates")
      expect(problem_report.content_item.organisations).to eq([hmrc])
    end
  end
end
