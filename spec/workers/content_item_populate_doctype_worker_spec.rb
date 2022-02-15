require "rails_helper"
require "gds_api/test_helpers/content_store"

describe ContentItemPopulateDoctypeWorker do
  include GdsApi::TestHelpers::ContentStore

  it "updates every content item's `document_type`" do
    content_item = double("ContentItem", path: "foo")
    allow(ContentItem).to receive(:all).and_return([content_item])
    mock_content_store = double("ContentStore", content_item: { "document_type" => "foo_doctype" })
    allow(GdsApi::ContentStore).to receive(:new).and_return(mock_content_store)

    expect(content_item).to receive(:update!).with(document_type: "foo_doctype")

    described_class.new.perform
  end
end
