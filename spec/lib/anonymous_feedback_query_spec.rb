require "rails_helper"
require "anonymous_feedback_query"

describe AnonymousFeedbackQuery do
  describe "#options" do
    subject(:options) { described_class.new(query_string).options }

    context "with paths in each of the three formats the explorer uses" do
      let(:query_string) { "path=/a&paths=/b&paths[]=/c" }

      it "collects all of them as path prefixes" do
        expect(options[:path_prefixes]).to contain_exactly("/a", "/b", "/c")
      end
    end

    context "with the same path in more than one format" do
      let(:query_string) { "path=/a&paths[]=/a" }

      it "keeps a single prefix" do
        expect(options[:path_prefixes]).to eq(["/a"])
      end
    end

    context "with an organisation" do
      let(:query_string) { "organisation=dvsa" }

      it "maps it as the organisation slug" do
        expect(options).to include(organisation_slug: "dvsa")
      end
    end

    context "with a document type" do
      let(:query_string) { "document_type=guide" }

      it "passes it through" do
        expect(options).to include(document_type: "guide")
      end
    end

    context "with ISO dates" do
      let(:query_string) { "from=2026-01-03&to=2026-07-02" }

      it "parses them" do
        expect(options).to include(from: Date.new(2026, 1, 3), to: Date.new(2026, 7, 2))
      end
    end

    context "with dates in the format the explorer's date fields submit" do
      let(:query_string) { "from=1+May+2026&to=16+May+2026" }

      it "parses them" do
        expect(options).to include(from: Date.new(2026, 5, 1), to: Date.new(2026, 5, 16))
      end
    end

    context "with dates the wrong way round" do
      let(:query_string) { "from=2026-03-31&to=2026-01-01" }

      it "sorts them, as the controller does" do
        expect(options).to include(from: Date.new(2026, 1, 1), to: Date.new(2026, 3, 31))
      end
    end

    context "with an unparseable date" do
      let(:query_string) { "paths=/a&from=soon" }

      it "leaves it unset, so the query stays unbounded" do
        expect(options[:from]).to be_nil
      end
    end

    context "with blank values" do
      let(:query_string) { "document_type=&organisation=&paths=/a" }

      it "ignores them rather than filtering on empty strings" do
        expect(options).to include(organisation_slug: nil, document_type: nil)
      end
    end
  end

  describe "#page" do
    it "returns the requested page number" do
      expect(described_class.new("paths=/a&page=82").page).to eq(82)
    end

    it "is zero when no page is requested" do
      expect(described_class.new("paths=/a").page).to eq(0)
    end
  end
end
