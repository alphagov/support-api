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
    before { login_as_stub_user }

    let!(:no_doctype_content_items) do
      create(
        :content_item,
        document_type: "",
        created_at: 2.days.ago,
        anonymous_contacts: create_list(:anonymous_contact, 2, created_at: 2.days.ago),
      )
    end
    let!(:nil_doctype_content_items) do
      create(
        :content_item,
        document_type: nil,
        created_at: 2.days.ago,
        anonymous_contacts: create_list(:anonymous_contact, 3, created_at: 2.days.ago),
      )
    end
    let!(:sa_content_items) do
      create(
        :content_item,
        document_type: "smart_answer",
        created_at: 70.days.ago,
        anonymous_contacts: create_list(:anonymous_contact, 1, created_at: 70.days.ago),
      )
    end
    let!(:cs_content_items) do
      create(
        :content_item,
        document_type: "case_study",
        created_at: 32.days.ago,
        anonymous_contacts: create_list(:anonymous_contact, 4, created_at: 32.days.ago),
      )
    end

    context "with no ordering" do
      subject { response }

      it "returns the last_7_days ordered summary for smart_answer" do
        get :show, params: { document_type: "smart_answer" }

        expect(JSON.parse(subject.body)).to eq(
          "document_type" => "smart_answer",
          "anonymous_feedback_counts" => [
            {
              "path" => "/search",
              "last_7_days" => 0,
              "last_30_days" => 0,
              "last_90_days" => 1,
            },
          ],
        )
      end
    end

    context "with a valid ordering" do
      subject { response }

      it "returns the ordered summary for the document_type" do
        get :show, params: { document_type: "smart_answer", ordering: "last_30_days" }

        expect(JSON.parse(subject.body)).to eq(
          "document_type" => "smart_answer",
          "anonymous_feedback_counts" => [
            {
              "path" => "/search",
              "last_7_days" => 0,
              "last_30_days" => 0,
              "last_90_days" => 1,
            },
          ],
        )
      end

      it "returns the ordered summary for case_study" do
        get :show, params: { document_type: "case_study", ordering: "last_30_days" }

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
    end

    context "with invalid ordering" do
      before { get :show, params: { document_type: "smart_answer", ordering: "foobar" } }
      subject { response }
      it { is_expected.to be_successful }

      it "returns the default ordered summary for the organisation" do
        expect(JSON.parse(subject.body)).to eq(
          "document_type" => "smart_answer",
          "anonymous_feedback_counts" => [
            {
              "path" => "/search",
              "last_7_days" => 0,
              "last_30_days" => 0,
              "last_90_days" => 1,
            },
          ],
        )
      end
    end

    context "with an invalid document_type" do
      before { get :show, params: { document_type: "invalid_document_type" } }

      subject { response }

      it { is_expected.to be_not_found }
    end

    context "with an empty document_type" do
      before { get :show, params: { document_type: "" } }

      subject { response }

      it "returns the default ordered summary for the organisation" do
        expect(JSON.parse(subject.body)).to eq(
          "document_type" => "",
          "anonymous_feedback_counts" => [
            {
              "path" => "/search",
              "last_7_days" => 2,
              "last_30_days" => 2,
              "last_90_days" => 2,
            },
          ],
        )
      end
    end
  end
end
