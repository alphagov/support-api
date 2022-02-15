require "rails_helper"

describe ProblemReportPresenter do
  describe "#initialize" do
    it "takes a ProblemReport as an argument" do
      expect { described_class.new }.to raise_exception(ArgumentError)
      expect { described_class.new(build(:problem_report)) }.not_to raise_exception
    end
  end

  describe ".header_row" do
    it "returns an array of header names" do
      expect(described_class.header_row).to eq([
        "where feedback was left",
        "creation date",
        "feedback",
        "user came from",
      ])
    end
  end

  describe "#to_a" do
    it "presents the correct columns" do
      problem_report = build(
        :problem_report,
        created_at: Time.utc(2015, 4),
        what_doing: "Finding the thing",
        what_wrong: "Couldn't find the thing\nThanks",
      )

      expect(described_class.new(problem_report).to_a).to eq([
        "http://www.dev.gov.uk/vat-rates",
        "2015-04-01",
        "action: Finding the thing\nproblem: Couldn't find the thing\nThanks",
        "http://www.example.com/foo",
      ])
    end
  end
end
