require "rails_helper"

describe GlobalExportCsvGenerator do
  let(:from_date) { Date.new(2015, 6, 1) }
  let(:to_date) { Date.new(2015, 6, 5) }

  before do
    (from_date..to_date).each { |d| create(:problem_report, created_at: d) }
    2.times.map { create(:problem_report, created_at: from_date + 1.day) }
    2.times { create(:problem_report, created_at: from_date - 1.day) }
    2.times { create(:problem_report, reviewed: true, marked_as_spam: true, created_at: from_date) }
  end

  let(:filename) { described_class.new(from_date, to_date, true).call.first }
  let(:result) { described_class.new(from_date, to_date, false).call.last }

  describe "#call" do
    context "with spam included" do
      it "returns the correct reports" do
        expect(result.split("\n")).to eq([
          "date,report_count",
          "2015-06-01,3",
          "2015-06-02,3",
          "2015-06-03,1",
          "2015-06-04,1",
          "2015-06-05,1",
        ])
      end
    end

    it "has 5 records and a header" do
      expect(result.split("\n").count).to eq(6)
    end

    it "is parseable as csv" do
      expect(CSV.parse(result).count).to eq(6)
    end

    it "returns a sane filename" do
      expect(filename).to eq("feedex_#{from_date.iso8601}_#{to_date.iso8601}_spam_excluded.csv")
    end

    context "with spam excluded" do
      let(:result) { described_class.new(from_date, to_date, true).call.last }

      it "returns the correct reports" do
        expect(result.split("\n")).to eq([
          "date,report_count",
          "2015-06-01,1",
          "2015-06-02,3",
          "2015-06-03,1",
          "2015-06-04,1",
          "2015-06-05,1",
        ])
      end
    end
  end
end
