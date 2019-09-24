require "rails_helper"

RSpec.describe AnonymousFeedback::OrganisationsController, type: :controller do
  describe "#show" do
    before { login_as_stub_user }

    let(:slug) { "ministry-of-magic" }
    let(:ordering) { "last_30_days" }

    subject do
      get :show, params: { slug: slug, ordering: ordering }
      response
    end

    context "with a valid organisation" do
      let!(:organisation) { create(:organisation) }

      it { is_expected.to be_successful }

      context "with a valid ordering" do
        it "returns the ordered summary for the organisation" do
          scope = double("scope")
          expect(ContentItem).to receive(:for_organisation).with(organisation)
            .and_return(scope)
          expect(scope).to receive(:summary).with("last_30_days").and_return([{
            "path" => "/", "last_7_days" => 1, "last_30_days" => 2, "last_90_days" => 3 
}])

          expect(JSON.parse(subject.body)).to eq(
            "slug" => "ministry-of-magic",
            "title" => "Ministry of Magic",
            "anonymous_feedback_counts" => [
              { "path" => "/", "last_7_days" => 1, "last_30_days" => 2, "last_90_days" => 3 },
            ],
          )
        end
      end

      context "with invalid ordering" do
        let(:ordering) { "foobar" }

        it "returns the default ordered summary for the organisation" do
          scope = double("scope")
          expect(ContentItem).to receive(:for_organisation).with(organisation)
            .and_return(scope)
          expect(scope).to receive(:summary).with("last_7_days").and_return([{
            "path" => "/", "last_7_days" => 1, "last_30_days" => 2, "last_90_days" => 3 
}])

          expect(JSON.parse(subject.body)).to eq(
            "slug" => "ministry-of-magic",
            "title" => "Ministry of Magic",
            "anonymous_feedback_counts" => [
              { "path" => "/", "last_7_days" => 1, "last_30_days" => 2, "last_90_days" => 3 },
            ],
          )
        end
      end
    end

    context "with an invalid organisation" do
      it { is_expected.to be_not_found }
    end
  end
end
