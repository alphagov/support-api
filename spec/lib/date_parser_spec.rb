require "rails_helper"
require "date_parser"

describe DateParser do
  subject() { described_class.parse(input) }

  context "with a valid short form date" do
    let(:input) { "13/10/2014" }
    it { is_expected.to eq(Date.new(2014, 10, 13)) }
  end

  context "with a valid long form date" do
    let(:input) { "1st December 2014" }
    it { is_expected.to eq(Date.new(2014, 12, 1)) }
  end
  context "with a nil date" do
    let(:input) { nil }
    it { is_expected.to be_nil }
  end

  context "with an invalid date" do
    let(:input) { "foo" }
    it { is_expected.to be_nil }
  end
end
