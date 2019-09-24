require "rails_helper"
require "date"
require "gds_api/test_helpers/performance_platform/data_in"

describe ServiceFeedbackPPUploaderWorker do
  include GdsApi::TestHelpers::PerformancePlatform::DataIn

  before do
    Timecop.travel Date.new(2013,2,11)
  end

  it "pushes yesterday's stats for each slug to the performance platform" do
    create(:service_feedback, slug: "waste_carrier_or_broker_registration")
    create(:service_feedback, slug: "apply_carers_allowance")

    create(:aggregated_service_feedback, slug: "waste_carrier_or_broker_registration", created_at: Date.yesterday)
    create(:aggregated_service_feedback, slug: "apply_carers_allowance", created_at: Date.yesterday)

    stub_post1 = stub_service_feedback_day_aggregate_submission("apply_carers_allowance")
    stub_post2 = stub_service_feedback_day_aggregate_submission("waste_carrier_or_broker_registration")

    ServiceFeedbackPPUploaderWorker.run

    expect(stub_post1).to have_been_made
    expect(stub_post2).to have_been_made
  end

  it "ignores errors arising from a dataset not existing in the Performance Platform" do
    # as of Dec 2015, creating service feedback datasets for each new transaction
    # in the Performance Platform is a manual process done by the PP team.
    # It's often the case that feedback starts coming into the Support API for
    # transactions that don't yet have a dataset for collecting this data.

    # Until the dataset is created, the Support API should silently consume the
    # failure. The data is still retained in the Support API DB, in case it needs
    # to be backfilled to the PP.
    create(:service_feedback, slug: "waste_carrier_or_broker_registration")
    create(:aggregated_service_feedback, slug: "waste_carrier_or_broker_registration", created_at: Date.yesterday)
    request = stub_pp_dataset_unavailable

    expect { ServiceFeedbackPPUploaderWorker.run }.to_not raise_error

    expect(request).to have_been_made
  end
end
