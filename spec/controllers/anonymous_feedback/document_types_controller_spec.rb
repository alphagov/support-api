require "rails_helper"

RSpec.describe AnonymousFeedback::DocumentTypesController, type: :controller do
  describe "#index" do
    before { login_as_stub_user }

    context "with existing content items" do
      let!(:sa_content_items) { create_list(:content_item, 2, document_type: "smart_answer") }
      let!(:cs_content_items) { create_list(:content_item, 3, document_type: "case_study") }
      let!(:no_doctype_content_items) { create_list(:content_item, 3, document_type: "") }
      let!(:nil_doctype_content_items) { create_list(:content_item, 3, document_type: nil) }

      before do
        get :index
      end

      subject { response }

      it { is_expected.to be_successful }

      it "returns a result" do
        expect(JSON.parse(response.body)).to be_eql(%w[case_study smart_answer])
      end

      it "filters out nils" do
        expect(JSON.parse(response.body)).to_not include(nil)
      end

      it "filters out blank document types" do
        expect(JSON.parse(response.body)).to_not include("")
      end
    end

    context "with no content items" do
      before do
        get :index
      end

      subject { response }

      it { is_expected.to be_successful }

      it "returns an empty array" do
        expect(JSON.parse(response.body)).to be_eql([])
      end
    end
  end

  describe "#show" do
    before do
      create(
        :content_item,
        document_type: "case_study",
        created_at: 32.days.ago,
        anonymous_contacts: create_list(:anonymous_contact, 4, created_at: 32.days.ago),
      )

      create(
        :content_item,
        path: "/really-bad-now",
        document_type: "smart_answer",
        anonymous_contacts: [
          create(:anonymous_contact, created_at: 3.days.ago),
        ],
      )
      create(
        :content_item,
        path: "/really-bad-last-week",
        document_type: "smart_answer",
        anonymous_contacts: create_list(
          :anonymous_contact,
          2,
          created_at: 9.days.ago,
        ),
      )
      create(
        :content_item,
        path: "/really-bad-last-month",
        document_type: "smart_answer",
        anonymous_contacts: create_list(
          :anonymous_contact,
          3,
          created_at: 40.days.ago,
        ),
      )

      login_as_stub_user
    end

    subject { response }

    it "returns a feedback summary for the given document type" do
      get :show, params: { document_type: "case_study" }

      expect(JSON.parse(subject.body)).to eq(
        "document_type" => "case_study",
        "anonymous_feedback_counts" => [
          {
            "path" => "/search",
            "last_7_days" => 0,
            "last_30_days" => 0,
            "last_90_days" => 4,
          },
        ],
      )
    end

    context "with an invalid document_type" do
      it "responds with a not found status" do
        get :show, params: { document_type: "invalid_document_type" }

        expect(subject.status).to eq(404)
      end
    end

    context "with no ordering" do
      it "returns a feedback summary ordered by last 7 day counts" do
        get :show, params: { document_type: "smart_answer" }

        expect(JSON.parse(subject.body)).to eq(
          "document_type" => "smart_answer",
          "anonymous_feedback_counts" => [
            {
              "path" => "/really-bad-now",
              "last_7_days" => 1,
              "last_30_days" => 1,
              "last_90_days" => 1,
            },
            {
              "path" => "/really-bad-last-week",
              "last_7_days" => 0,
              "last_30_days" => 2,
              "last_90_days" => 2,
            },
            {
              "path" => "/really-bad-last-month",
              "last_7_days" => 0,
              "last_30_days" => 0,
              "last_90_days" => 3,
            },
          ],
        )
      end
    end

    context "with a valid ordering" do
      it "returns a custom-ordered feedback summary" do
        get :show, params: {
          document_type: "smart_answer",
          ordering: "last_30_days",
        }

        expect(JSON.parse(subject.body)).to eq(
          "document_type" => "smart_answer",
          "anonymous_feedback_counts" => [
            {
              "path" => "/really-bad-last-week",
              "last_7_days" => 0,
              "last_30_days" => 2,
              "last_90_days" => 2,
            },
            {
              "path" => "/really-bad-now",
              "last_7_days" => 1,
              "last_30_days" => 1,
              "last_90_days" => 1,
            },
            {
              "path" => "/really-bad-last-month",
              "last_7_days" => 0,
              "last_30_days" => 0,
              "last_90_days" => 3,
            },
          ],
        )
      end
    end

    context "with invalid ordering" do
      it "returns a feedback summary ordered by last 7 day counts" do
        get :show, params: { document_type: "smart_answer", order: "foobar" }

        expect(JSON.parse(subject.body)).to eq(
          "document_type" => "smart_answer",
          "anonymous_feedback_counts" => [
            {
              "path" => "/really-bad-now",
              "last_7_days" => 1,
              "last_30_days" => 1,
              "last_90_days" => 1,
            },
            {
              "path" => "/really-bad-last-week",
              "last_7_days" => 0,
              "last_30_days" => 2,
              "last_90_days" => 2,
            },
            {
              "path" => "/really-bad-last-month",
              "last_7_days" => 0,
              "last_30_days" => 0,
              "last_90_days" => 3,
            },
          ],
        )
      end
    end
  end
end
