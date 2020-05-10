require "rails_helper"
require "content_store_lookup"
require "plek"
require "gds_api/test_helpers/content_store"

describe ContentStoreLookup, "#lookup" do
  include GdsApi::TestHelpers::ContentStore

  let(:content_store) { GdsApi::ContentStore.new(Plek.find("content-store")) }
  let(:subject) { ContentStoreLookup.new(content_store) }

  let(:path) { "/contact-ukvi/overview" }

  context "when the response indicates the item is not present" do
    before do
      stub_content_store_does_not_have_item(path)
    end

    it "returns nil" do
      expect(subject.lookup(path)).to eq nil
    end
  end

  context "when the response indicates the item has gone" do
    before do
      content_store_has_gone_item(path)
    end

    it "returns nil" do
      expect(subject.lookup(path)).to eq nil
    end
  end
end
