require 'rails_helper'

describe FeedbackCsvRowPresenter do
  subject(:instance) { described_class.new(row) }
  let(:problem_report) { build(:problem_report, created_at: Time.utc(2015,4), what_doing: "Finding the thing", what_wrong: "Couldn't find the thing\nThanks") }
  let(:service_feedback) { build(:service_feedback, created_at: Time.utc(2015,4), details: "It was good\nWell done", service_satisfaction_rating: 3) }
  let(:aggregated_service_feedback) { build(:aggregated_service_feedback, created_at: Time.utc(2015,4), details: 1, service_satisfaction_rating: 3) }
  let(:long_form_contact) { build(:long_form_contact, created_at: Time.utc(2015,4), details: "It was really good\nReally.\nGood job") }

  describe "#to_a" do
    subject { instance.to_a }

    context "for a problem report" do
      let(:row) { problem_report }

      it "presents the correct columns" do
        expect(subject).to eq [
          "2015-04-01 00:00:00",
          row.path,
          "#{row.what_doing}\n#{row.what_wrong}",
          "",
          "IE",
          "9.0",
          "Windows Vista",
          row.user_agent,
          "http://www.example.com/foo",
          "problem-report"
        ]
      end
    end

    context "for service feedback" do
      let(:row) { service_feedback }

      it "presents the correct columns" do
        expect(subject).to eq [
          "2015-04-01 00:00:00",
          row.slug,
          row.details,
          "3",
          "IE",
          "9.0",
          "Windows Vista",
          row.user_agent,
          "http://www.example.com/foo",
          "service-feedback"
        ]
      end
    end

    context "for aggregated service feedback" do
      let(:row) { aggregated_service_feedback }
      it "presents the correct columns" do
        expect(subject).to eq [
          "2015-04-01 00:00:00",
          row.path,
          "Rating of #{row.service_satisfaction_rating}: #{row.details}",
          "3",
          "IE",
          "9.0",
          "Windows Vista",
          row.user_agent,
          "http://www.example.com/foo",
          "aggregated-service-feedback"
        ]
      end
    end

    context "for long form contact" do
      let(:row) { long_form_contact }

      it "presents the correct columns" do
        expect(subject).to eq [
          "2015-04-01 00:00:00",
          row.path,
          row.details,
          "",
          "IE",
          "9.0",
          "Windows Vista",
          row.user_agent,
          "http://www.example.com/foo",
          "long-form-contact"
        ]
      end
    end
  end

  describe "#details_text" do
    subject { instance.details_text }
    context "for a problem report" do
      let(:row) { problem_report }

      it "is what_doing and what_wrong joined with a newline" do
        expect(subject).to eq "Finding the thing\nCouldn't find the thing\nThanks"
      end
    end

    context "for service feedback" do
      let(:row) { service_feedback }

      it { is_expected.to eq("It was good\nWell done") }
    end

    context "for long form contact" do
      let(:row) { long_form_contact }

      it { is_expected.to eq("It was really good\nReally.\nGood job") }
    end

    context "for aggregated service feedback" do
      let(:row) { aggregated_service_feedback }

      it 'is a sentence explaining the rating and how many ratings there were' do
        expect(subject).to eq("Rating of 3: 1")
      end
    end
  end
end
