require 'rails_helper'

describe AnonymousFeedback::GlobalExportRequestsController, type: :controller do
  describe "#create" do
    context "with valid parameters" do
      it "succeeds" do
        expect(GenerateGlobalExportCsvWorker).to receive(:perform_async).once

        response = post :create, global_export_request: {
          from_date: "2015-05-01",
          to_date: "2015-06-01",
          notification_email: "foo@example.com",
        }

        expect(response).to be_accepted
      end
    end

    context "with invalid parameters" do
      it "fails" do
        expect(GenerateGlobalExportCsvWorker).not_to receive(:perform_async)

        response = post :create, global_export_request: {
          from_date: "2015-05-01",
          to_date: "2015-06-01",
        }

        expect(response).to be_unprocessable
      end
    end
  end
end
