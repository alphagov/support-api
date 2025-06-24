require "rails_helper"

RSpec.describe AnonymousFeedback::OrganisationsController, type: :controller do
  describe "#show" do
    let(:org_1) { create(:organisation, slug: "org-1") }
    let(:org_2) { create(:organisation, slug: "org-2") }

    before do
      create(
        :content_item,
        organisations: [org_1],
        created_at: 32.days.ago,
        anonymous_contacts: create_list(:anonymous_contact, 4, created_at: 32.days.ago),
      )

      create(
        :content_item,
        path: "/really-bad-now",
        organisations: [org_2],
        anonymous_contacts: [
          create(:anonymous_contact, created_at: 3.days.ago),
        ],
      )
      create(
        :content_item,
        path: "/really-bad-last-week",
        organisations: [org_2],
        anonymous_contacts: create_list(
          :anonymous_contact,
          2,
          created_at: 9.days.ago,
        ),
      )
      create(
        :content_item,
        path: "/really-bad-last-month",
        organisations: [org_2],
        anonymous_contacts: create_list(
          :anonymous_contact,
          3,
          created_at: 40.days.ago,
        ),
      )

      login_as_stub_user
    end

    subject { response }

    it "returns a feedback summary for the given organisation" do
      get :show, params: { slug: "org-1" }

      expect(JSON.parse(subject.body)).to eq(
        "slug" => "org-1",
        "title" => org_1.title,
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

    context "with an invalid organisation slug" do
      before do
        get :show, params: { slug: "invalid-organisation-slug" }
      end

      it { is_expected.to be_not_found }
    end

    context "with no ordering" do
      it "returns a feedback summary ordered by last 7 day counts" do
        get :show, params: { slug: "org-2" }

        expect(JSON.parse(subject.body)).to eq(
          "slug" => "org-2",
          "title" => org_2.title,
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
        get :show, params: { slug: "org-2", ordering: "last_30_days" }

        expect(JSON.parse(subject.body)).to eq(
          "slug" => "org-2",
          "title" => org_2.title,
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
        get :show, params: { slug: "org-2", order: "foobar" }

        expect(JSON.parse(subject.body)).to eq(
          "slug" => "org-2",
          "title" => org_2.title,
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
