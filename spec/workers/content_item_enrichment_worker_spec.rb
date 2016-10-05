require 'rails_helper'
require 'gds_api/test_helpers/content_store'
require 'gds_api/test_helpers/content_api'

describe ContentItemEnrichmentWorker do
  include GdsApi::TestHelpers::ContentStore
  include GdsApi::TestHelpers::ContentApi

  let(:raw_path) { 'my-magic-govuk-endpoint' }
  let(:path) { "/#{raw_path}" }
  let(:problem_report) { create(:problem_report, path: path) }
  subject(:worker) { described_class.new }

  context "with an entry in both the content api and content store" do
    before do
      create(:gds)
      content_store_has_item(path)
      content_api_has_an_artefact(raw_path)
    end

    context "without an existing content item" do
      it "creates a new content item" do
        expect(ContentItem.count).to eq(0)
        worker.perform(problem_report.id)
        expect(ContentItem.count).to eq(1)
      end
    end

    context "with an existing content item" do
      it "uses the existing content item" do
        create(:content_item, path: path)

        expect { worker.perform(problem_report.id) }.to_not change { ContentItem.count }
      end
    end
  end

  context "with an entry in the content api" do
    before do
      create(:gds)
      content_store_does_not_have_item(path)
      content_api_has_an_artefact(raw_path)
    end

    context "without an existing content item" do
      it "creates a new content item" do
        expect(ContentItem.count).to eq(0)
        worker.perform(problem_report.id)
        expect(ContentItem.count).to eq(1)
      end
    end

    context "with an existing content item" do
      it "uses the existing content item" do
        create(:content_item, path: path)

        expect { worker.perform(problem_report.id) }.to_not change { ContentItem.count }
      end
    end
  end

  context "with an entry in the content store" do
    before do
      create(:gds)
      content_store_has_item(path)
      content_api_does_not_have_an_artefact(raw_path)
    end

    context "without an existing content item" do
      it "creates a new content item" do
        expect(ContentItem.count).to eq(0)
        worker.perform(problem_report.id)
        expect(ContentItem.count).to eq(1)
      end
    end

    context "with an existing content item" do
      it "uses the existing content item" do
        create(:content_item, path: path)

        expect { worker.perform(problem_report.id) }.to_not change { ContentItem.count }
      end
    end
  end
end
