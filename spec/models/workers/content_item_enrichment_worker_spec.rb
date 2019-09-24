require "rails_helper"
require "gds_api/test_helpers/content_store"

describe ContentItemEnrichmentWorker do
  include GdsApi::TestHelpers::ContentStore

  subject { ContentItemEnrichmentWorker.new }

  context "for a problem report about a piece of content we can't determine the organisation for" do
    let(:problem_report) { create(:problem_report, path: "/unknown-org-page") }
    let!(:gds) { create(:gds) }

    before do
      content_store_does_not_have_item("/unknown-org-page")
      subject.perform(problem_report.id)
      problem_report.reload
    end

    it "assigns the problem_report to GDS" do
      expect(problem_report.content_item.path).to eq("/unknown-org-page")
      expect(problem_report.content_item.organisations).to eq([gds])
    end
  end

  context "for a problem report about a piece of content we know the organisation of" do
    let(:hmrc) { Organisation.where(slug: "hm-revenue-customs").first }
    let(:vat_rates_content_store_response) {
      {
        base_path: "/vat-rates",
        title: "VAT Rates",
        links: {
          organisations: [
            {
              content_id: "6667cce2-e809-4e21-ae09-cb0bdc1ddda3",
              base_path: "/hm-revenue-customs",
              title: "HM Revenue & Customs",
              document_type: "organisation",
            },
          ],
        },
      }
    }

    let(:problem_report) { create(:problem_report, path: "/vat-rates") }

    before do
      content_store_has_item("/vat-rates", vat_rates_content_store_response)
      subject.perform(problem_report.id)
      problem_report.reload
    end

    it "assigns the problem report to the organisation" do
      expect(problem_report.content_item.path).to eq("/vat-rates")
      expect(problem_report.content_item.organisations).to eq([hmrc])
    end
  end

  context "for a problem report about a piece of content whose organisation has changed" do
    let(:hmrc) { Organisation.find_by(slug: "hm-revenue-customs") }
    let(:aaib) { Organisation.find_by(slug: "air-accidents-investigation-branch") }
    let(:vat_rates_content_store_response) {
      {
        base_path: "/vat-rates",
        title: "VAT Rates",
        links: {
          organisations: [
            {
              content_id: "6667cce2-e809-4e21-ae09-cb0bdc1ddda3",
              base_path: "/hm-revenue-customs",
              title: "HM Revenue & Customs",
              document_type: "organisation",
            }
          ],
        },
      }
    }
    let(:vat_rates_content_store_response_new) {
      {
        base_path: "/vat-rates",
        title: "VAT Rates",
        links: {
          organisations: [
            {
              content_id: "38eb5d8f-2d89-480c-8655-e2e7ac23f8f4",
              base_path: "/air-accidents-investigation-branch",
              title: "aaib",
              document_type: "organisation",
            }
          ],
        },
      }
    }

    let(:problem_report) { create(:problem_report, path: "/vat-rates") }

    before do
      content_store_has_item("/vat-rates", vat_rates_content_store_response)
      subject.perform(problem_report.id)
      problem_report.reload
    end

    it "assigns the problem report to the new organisation" do
      expect(problem_report.content_item.organisations).to eq([hmrc])
      content_store_has_item("/vat-rates", vat_rates_content_store_response_new)
      subject.perform(problem_report.id)
      problem_report.reload
      expect(problem_report.content_item.organisations).to eq([aaib])
    end
  end
end
