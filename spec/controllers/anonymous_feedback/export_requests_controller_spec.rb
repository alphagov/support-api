require "rails_helper"

RSpec.describe AnonymousFeedback::ExportRequestsController, type: :controller do
  describe "#create" do
    before { login_as_stub_user }

    context "posted with valid parameters" do
      before do
        expect(GenerateFeedbackCsvJob).to receive(:perform_async).once.with(instance_of(Integer))
        post :create,
             params: {
               export_request: {
                 from: "2015-05-01",
                 to: "2015-06-01",
                 path_prefixes: ["/"],
                 notification_email: "foo@example.com",
                 organisation: "",
                 document_type: "",
               },
             }
      end

      subject { response }

      it { is_expected.to be_accepted }

      it "creates a feedback export request with the correct filters" do
        expect(FeedbackExportRequest.count).to eq(1)
        feedback_export_request = FeedbackExportRequest.last

        expect(feedback_export_request.filters).to eq(
          from: Date.new(2015, 0o5, 0o1),
          to: Date.new(2015, 0o6, 0o1),
          organisation_slug: "",
          path_prefixes: ["/"],
          document_type: "",
        )
      end
    end

    context "posted with invalid parameters" do
      before do
        expect(GenerateFeedbackCsvJob).to receive(:perform_async).never
        post :create,
             params: {
               export_request: {
                 from: "2015-05-01",
                 to: "2015-06-01",
                 path_prefixes: ["/"],
                 organisation: "",
                 document_type: "",
               },
             }
      end

      subject { response }

      it { is_expected.to be_unprocessable }
    end

    context "with backwards compatible `path_prefix` param" do
      before do
        expect(GenerateFeedbackCsvJob).to receive(:perform_async).once.with(instance_of(Integer))
        post :create,
             params: {
               export_request:
                 {
                   from: "2015-05-01",
                   to: "2015-06-01",
                   path_prefix: "/",
                   notification_email: "foo@example.com",
                   organisation: "",
                   document_type: "",
                 },
             }
      end

      subject { response }

      it { is_expected.to be_accepted }

      it "creates a feedback export request with the correct filters" do
        expect(FeedbackExportRequest.count).to eq(1)
        feedback_export_request = FeedbackExportRequest.last

        expect(feedback_export_request.filters).to eq(
          from: Date.new(2015, 0o5, 0o1),
          to: Date.new(2015, 0o6, 0o1),
          path_prefixes: ["/"],
          organisation_slug: "",
          document_type: "",
        )
      end
    end
  end

  describe "#show" do
    before do
      login_as_stub_user
      get :show, params: { id: }
    end

    subject { response }

    context "requesting a non-existant export request" do
      let(:id) { 1 }

      it { is_expected.to be_not_found }
    end

    context "requesting a pending export request" do
      let(:export_request) { create(:feedback_export_request) }
      let(:id) { export_request.id }

      it { is_expected.to be_successful }

      it "returns the URL" do
        expect(JSON.parse(response.body)["filename"]).to eq export_request.filename
      end

      it "returns a status of not ready" do
        expect(JSON.parse(response.body)["ready"]).to be false
      end
    end

    context "requesting a processed export request" do
      let(:export_request) { create(:feedback_export_request, generated_at: Time.zone.now) }
      let(:id) { export_request.id }

      it { is_expected.to be_successful }

      it "returns the URL" do
        expect(JSON.parse(response.body)["filename"]).to eq export_request.filename
      end

      it "returns a status of ready" do
        expect(JSON.parse(response.body)["ready"]).to be true
      end
    end
  end
end
