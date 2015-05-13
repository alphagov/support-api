require 'rails_helper'

describe AnonymousFeedbackController do
  describe "#index" do
    it "is a bad request with no `path_prefix`" do
      get :index
      expect(response).to have_http_status(400)
    end

    it "is successful with valid `path_prefix`" do
      create_list(:anonymous_contact, 2, path: "/tax-disc")
      get :index, path_prefix: "/tax-disc"
      expect(response).to be_success
    end

    it "returns an empty result when no results are found" do
      get :index, path_prefix: "/non-existent"

      expect(response).to be_success
      expect(json_response).to eq(
        "results" => [],
        "page_size" => 50,
        "total_count" => 0,
        "current_page" => 1,
        "pages" => 0,
      )
    end

    it "returns an empty result if the user has gone beyond the last page" do
      create_list(:anonymous_contact, 2, path: "/tax-disc")
      get :index, path_prefix: "/tax-disc", page: 2

      expect(json_response).to eq(
        "results" => [],
        "page_size" => 50,
        "total_count" => 2,
        "current_page" => 2,
        "pages" => 1,
      )
    end
  end
end
