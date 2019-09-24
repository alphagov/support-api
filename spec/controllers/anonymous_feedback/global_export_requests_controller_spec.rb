require "rails_helper"

describe AnonymousFeedback::GlobalExportRequestsController, type: :controller do
  describe "#create" do
    before { login_as_stub_user }

    context "with valid parameters" do
      it "succeeds" do
        expect(GenerateGlobalExportCsvWorker).to receive(:perform_async).once

        response = post :create, params: {
          global_export_request: {
            from_date: "2015-05-01",
            to_date: "2015-06-01",
            notification_email: "foo@example.com",
            exclude_spam: true
          }
        }

        expect(response).to be_accepted
      end
    end

    context "with invalid parameters" do
      it "fails" do
        expect(GenerateGlobalExportCsvWorker).not_to receive(:perform_async)

        response = post :create, params: {
          global_export_request: {
            from_date: "2015-05-01",
            to_date: "2015-06-01",
          }
        }

        expect(response).to be_unprocessable
      end
    end
  end
end
