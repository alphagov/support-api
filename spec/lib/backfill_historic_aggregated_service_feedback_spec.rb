require "backfill_historic_aggregated_service_feedback"
require "gds_api/test_helpers/performance_platform/data_out"
require "rails_helper"

describe BackfillHistoricAggregatedServiceFeedback, "#import_from_performance_platform" do
  include GdsApi::TestHelpers::PerformancePlatform::DataOut

  let(:start_date) { Date.new(2014, 6, 10) }
  let(:end_date) { Date.new(2014, 6, 11) }
  let(:transaction_slug) { "register-to-vote" }
  let(:path_for_transaction) { "/done/#{transaction_slug}" }
  let(:test_logger) { Rails.logger }
  let(:subject) { described_class.new(start_date, end_date, test_logger) }
  let(:other_transaction_slug) { "register-to-vote-other" }

  let(:service_feedback_json) {
    {
      "data": [
        {
          "_day_start_at": "2014-06-10T00:00:00+00:00",
          "_hour_start_at": "2014-06-10T00:00:00+00:00",
          "_id": "20140610_register-to-vote",
          "_month_start_at": "2014-06-01T00:00:00+00:00",
          "_quarter_start_at": "2014-04-01T00:00:00+00:00",
          "_timestamp": "2014-06-10T00:00:00+00:00",
          "_updated_at": "2014-06-11T00:30:50.901000+00:00",
          "_week_start_at": "2014-06-09T00:00:00+00:00",
          "comments": 0,
          "period": "day",
          "rating_1": 1,
          "rating_2": 3,
          "rating_3": 5,
          "rating_4": 7,
          "rating_5": 9,
          "slug": "register-to-vote",
          "total": 25,
        },
        {
          "_day_start_at": "2014-06-10T00:00:00+00:00",
          "_hour_start_at": "2014-06-10T00:00:00+00:00",
          "_id": "20140610_register-to-vote",
          "_month_start_at": "2014-06-01T00:00:00+00:00",
          "_quarter_start_at": "2014-04-01T00:00:00+00:00",
          "_timestamp": "2014-06-10T00:00:00+00:00",
          "_updated_at": "2014-06-11T00:30:50.901000+00:00",
          "_week_start_at": "2014-06-09T00:00:00+00:00",
          "comments": 0,
          "period": "day",
          "rating_1": 10,
          "rating_2": 30,
          "rating_3": 50,
          "rating_4": 70,
          "rating_5": 90,
          "slug": other_transaction_slug,
          "total": 25,
        },
        {
          "_day_start_at": "2014-06-11T00:00:00+00:00",
          "_hour_start_at": "2014-06-11T00:00:00+00:00",
          "_id": "20140611_register-to-vote",
          "_month_start_at": "2014-06-01T00:00:00+00:00",
          "_quarter_start_at": "2014-04-01T00:00:00+00:00",
          "_timestamp": "2014-06-11T00:00:00+00:00",
          "_updated_at": "2014-06-12T00:30:54.317000+00:00",
          "_week_start_at": "2014-06-09T00:00:00+00:00",
          "comments": 0,
          "period": "day",
          "rating_1": 3,
          "rating_2": 5,
          "rating_3": 7,
          "rating_4": 9,
          "rating_5": 0,
          "slug": "register-to-vote",
          "total": 35,
        },
        {
          "_day_start_at": "2014-06-12T00:00:00+00:00",
          "_hour_start_at": "2014-06-12T00:00:00+00:00",
          "_id": "20140612_register-to-vote",
          "_month_start_at": "2014-06-01T00:00:00+00:00",
          "_quarter_start_at": "2014-04-01T00:00:00+00:00",
          "_timestamp": "2014-06-12T00:00:00+00:00",
          "_updated_at": "2014-06-13T00:30:55.411000+00:00",
          "_week_start_at": "2014-06-09T00:00:00+00:00",
          "comments": 122,
          "period": "day",
          "rating_1": 0,
          "rating_2": 3,
          "rating_3": 6,
          "rating_4": 38,
          "rating_5": 371,
          "slug": "register-to-vote",
          "total": 418,
        },
      ],
    }
  }

  let!(:earlier_aggregated_service_feedback) { create :aggregated_service_feedback, service_satisfaction_rating: 1, path: path_for_transaction, details: "2", created_at: start_date - 1.day }

  let!(:start_date_aggregated_service_feedback_rating_1) { create :aggregated_service_feedback, service_satisfaction_rating: 1, path: path_for_transaction, details: "2", created_at: start_date }
  let!(:start_date_aggregated_service_feedback_rating_2) { create :aggregated_service_feedback, service_satisfaction_rating: 2, path: path_for_transaction, details: "4", created_at: start_date }
  let!(:start_date_aggregated_service_feedback_rating_3) { create :aggregated_service_feedback, service_satisfaction_rating: 3, path: path_for_transaction, details: "6", created_at: start_date }
  let!(:start_date_aggregated_service_feedback_rating_4) { create :aggregated_service_feedback, service_satisfaction_rating: 4, path: path_for_transaction, details: "8", created_at: start_date }
  let!(:start_date_aggregated_service_feedback_rating_5) { create :aggregated_service_feedback, service_satisfaction_rating: 5, path: path_for_transaction, details: "10", created_at: start_date }

  let!(:end_date_aggregated_service_feedback_rating_1) { create :aggregated_service_feedback, service_satisfaction_rating: 1, path: path_for_transaction, details: "4", created_at: end_date }
  let!(:end_date_aggregated_service_feedback_rating_2) { create :aggregated_service_feedback, service_satisfaction_rating: 2, path: path_for_transaction, details: "6", created_at: end_date }
  let!(:end_date_aggregated_service_feedback_rating_3) { create :aggregated_service_feedback, service_satisfaction_rating: 3, path: path_for_transaction, details: "8", created_at: end_date }
  let!(:end_date_aggregated_service_feedback_rating_4) { create :aggregated_service_feedback, service_satisfaction_rating: 4, path: path_for_transaction, details: "10", created_at: end_date }
  let!(:end_date_aggregated_service_feedback_rating_5) { create :aggregated_service_feedback, service_satisfaction_rating: 5, path: path_for_transaction, details: "12", created_at: end_date }

  let(:later_aggregated_service_feedback) { create :aggregated_service_feedback, service_satisfaction_rating: 1, details: "4", path: path_for_transaction, created_at: end_date + 1.day }

  context "when the API is available" do
    let(:path_for_other_transaction) { "/done/#{other_transaction_slug}" }

    let!(:start_date_aggregated_service_feedback_rating_1_other_path) { create :aggregated_service_feedback, service_satisfaction_rating: 1, path: path_for_other_transaction, details: "2", created_at: start_date }
    let!(:start_date_aggregated_service_feedback_rating_2_other_path) { create :aggregated_service_feedback, service_satisfaction_rating: 2, path: path_for_other_transaction, details: "4", created_at: start_date }
    let!(:start_date_aggregated_service_feedback_rating_3_other_path) { create :aggregated_service_feedback, service_satisfaction_rating: 3, path: path_for_other_transaction, details: "6", created_at: start_date }
    let!(:start_date_aggregated_service_feedback_rating_4_other_path) { create :aggregated_service_feedback, service_satisfaction_rating: 4, path: path_for_other_transaction, details: "8", created_at: start_date }
    let!(:start_date_aggregated_service_feedback_rating_5_other_path) { create :aggregated_service_feedback, service_satisfaction_rating: 5, path: path_for_other_transaction, details: "10", created_at: start_date }

    before do
      @stub = stub_service_feedback(transaction_slug, service_feedback_json)
      subject.import_from_performance_platform(transaction_slug)
    end

    it "calls the performance platform endpoint for fetching service feedback" do
      expect(@stub).to have_been_requested
    end

    it "overwrites aggregated service feedback totals for all of the dates that are returned for that path" do
      expect(start_date_aggregated_service_feedback_rating_1.reload.details).to eq "1"
      expect(start_date_aggregated_service_feedback_rating_2.reload.details).to eq "3"
      expect(start_date_aggregated_service_feedback_rating_3.reload.details).to eq "5"
      expect(start_date_aggregated_service_feedback_rating_4.reload.details).to eq "7"
      expect(start_date_aggregated_service_feedback_rating_5.reload.details).to eq "9"

      expect(end_date_aggregated_service_feedback_rating_1.reload.details).to eq "3"
      expect(end_date_aggregated_service_feedback_rating_2.reload.details).to eq "5"
      expect(end_date_aggregated_service_feedback_rating_3.reload.details).to eq "7"
      expect(end_date_aggregated_service_feedback_rating_4.reload.details).to eq "9"
    end

    it "deletes aggregates in the case where the performance platform returns a count of zero" do
      expect(AggregatedServiceFeedback.find_by_id(end_date_aggregated_service_feedback_rating_5.id)).to be_falsy
    end

    it "does not change the aggregated feedback outside of the specified dates" do
      expect(earlier_aggregated_service_feedback.reload.details).to eq "2"
      expect(later_aggregated_service_feedback.reload.details).to eq "4"
    end

    it "does not change aggregated feedback for another path even if present in the JSON" do
      expect(start_date_aggregated_service_feedback_rating_1_other_path.reload.details).to eq "2"
      expect(start_date_aggregated_service_feedback_rating_2_other_path.reload.details).to eq "4"
      expect(start_date_aggregated_service_feedback_rating_3_other_path.reload.details).to eq "6"
      expect(start_date_aggregated_service_feedback_rating_4_other_path.reload.details).to eq "8"
      expect(start_date_aggregated_service_feedback_rating_5_other_path.reload.details).to eq "10"
    end
  end

  it "logs a success message once all specified feedback has been overwritten for that slug" do
    stub_service_feedback(transaction_slug, service_feedback_json)
    expect(test_logger).to receive(:info).with("AggregateServiceFeedback for slug '#{transaction_slug}' overwritten where possible between dates #{start_date} and #{end_date}")

    subject.import_from_performance_platform(transaction_slug)
  end

  context "when the slug does not match any available data set" do
    before do
      stub_data_set_not_available("register-to-adopt-panda")
    end

    it "logs a message" do
      expect(test_logger).to receive(:warn).with("No endpoint found in performance platform for register-to-adopt-panda")
      subject.import_from_performance_platform("register-to-adopt-panda")
    end
  end

  context "when the service returns an empty data array" do
    let(:empty_data_array) { { "data": [] } }

    before do
      stub_service_feedback(transaction_slug, empty_data_array)
    end

    it "logs a message" do
      expect(test_logger).to receive(:warn).with("No data found for endpoint #{transaction_slug}")
      subject.import_from_performance_platform(transaction_slug)
    end
  end

  context "when the slug does not match any aggregated service feedback record paths" do
    let(:slug) { "adopt-a-panda" }

    before do
      stub_service_feedback(slug, service_feedback_json)
    end

    it "logs a message" do
      expect(test_logger).to receive(:warn).with("No aggregated feedback found for path /done/adopt-a-panda")
      subject.import_from_performance_platform(slug)
    end
  end
end
