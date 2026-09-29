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
      stub_content_store_has_gone_item(path)
    end

    it "returns nil" do
      expect(subject.lookup(path)).to eq nil
    end
  end

  context "when the path is a smart answer that has underscores after the prefix" do
    let(:path) { "/am-i-eligible/y/y/over_sixty_five" }

    before do
      # ideally we'd stub the prefix like in a real smart answer, but
      # the test helpers don't support that.
      stub_content_store_has_item("/am-i-eligible/y/y/over-sixty-five")
    end

    it "does not log anything in Sentry" do
      expect(GovukError).not_to receive(:notify)

      subject.lookup(path)
    end

    it "gets the content item by an RFC-192 compliant path" do
      expect(subject.lookup(path)).not_to eq nil
    end
  end

  context "when the path is invalid" do
    let(:path) { "/am-I-eligible" }

    it "captures the error in Sentry" do
      expect(GovukError).to receive(:notify).with(
        "Unable to fetch from content store",
        {
          extra: {
            compliant_path: "/am-I-eligible",
            error_type: "GdsApi::HTTPBadRequest",
            path: "/am-I-eligible",
          },
          level: "error",
          tags: {},
        },
      )

      subject.lookup(path)
    end

    it "returns nil" do
      expect(subject.lookup(path)).to eq nil
    end
  end
end
