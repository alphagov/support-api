require 'rails_helper'

RSpec.describe OrganisationsController, type: :controller do
  describe "#index" do
    before do
      create :organisation, title: "Ministry of Magic"
      create :organisation, title: "Department of Fair Dos"
    end

    it "renders an ordered json list of organisations" do
      get :index
      expect(JSON.parse(response.body)).to eq [
        {
          "title" => "Department of Fair Dos",
          "slug" => "department-of-fair-dos",
          "acronym" => "DOFD",
          "govuk_status" => "live",
          "web_url" => "https://www.gov.uk/government/organisations/department-of-fair-dos"
        },
        {
          "title" => "Ministry of Magic",
          "slug" => "ministry-of-magic",
          "acronym" => "MOM",
          "govuk_status" => "live",
          "web_url" => "https://www.gov.uk/government/organisations/ministry-of-magic"
        }
      ]
    end
  end

  describe "#show" do
    context "for a valid organisation" do
      let!(:organisation) { create :organisation }

      it "renders the organisation as json" do
        get :show, slug: "ministry-of-magic"
        expect(JSON.parse(response.body)).to eq(
          "title" => "Ministry of Magic",
          "slug" => "ministry-of-magic",
          "acronym" => "MOM",
          "govuk_status" => "live",
          "web_url" => "https://www.gov.uk/government/organisations/ministry-of-magic"
        )
      end
    end

    context "for an invalid organisation" do
      it "returns a 404" do
        get :show, slug: "ministry-of-magic"

        expect(response).to be_not_found
      end
    end
  end
end
