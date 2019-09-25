require "rails_helper"

describe "/feedback-by-day endpoint" do
  before :each do
    create_list(:problem_report, 5, path: "/browse/abroad", created_at: Time.utc(2018, 0o2, 21))
    create_list(:problem_report, 4, path: "/browse/abroad", created_at: Time.utc(2018, 0o2, 22))
    create_list(:problem_report, 6, path: "/browse/benefits", created_at: Time.utc(2018, 0o2, 21))
    create_list(:problem_report, 2, path: "/browse/benefits", created_at: Time.utc(2018, 0o2, 22))
    create_list(:problem_report, 8, path: "/browse/tax", created_at: Time.utc(2018, 0o2, 21))
    create_list(:problem_report, 3, path: "/browse/tax", created_at: Time.utc(2018, 0o2, 22))
  end

  context "with invalid requests" do
    it "returns bad request for non date" do
      get_json "/feedback-by-day/blah"
      expect(response.status).to eq(400)
    end

    it "returns bad request for invalid date" do
      get_json "/feedback-by-day/2018-02-31"
      expect(response.status).to eq(400)
    end

    it "returns bad request for invalid page" do
      get_json "/feedback-by-day/2018-02-02?page=blah"
      expect(response.status).to eq(400)
    end

    it "returns bad request for invalid per_page" do
      get_json "/feedback-by-day/2018-02-02?per_page=blah"
      expect(response.status).to eq(400)
    end
  end

  context "with a valid request" do
    it "returns the correct figures for 2018-02-21" do
      get_json "/feedback-by-day/2018-02-21"
      expect(response.status).to eq(200)
      expect(json_response["results"]).to eq([
        {
          "path" => "/browse/abroad",
          "count" => 5,
        },
        {
          "path" => "/browse/benefits",
          "count" => 6,
        },
        {
          "path" => "/browse/tax",
          "count" => 8,
        },
      ])
      expect(json_response).to include(
        "total_count" => 3,
        "current_page" => 1,
        "pages" => 1,
        "page_size" => 100,
      )
    end

    it "returns the correct figures for 2018-02-22" do
      get_json "/feedback-by-day/2018-02-22"
      expect(response.status).to eq(200)
      expect(json_response["results"]).to eq([
        {
          "path" => "/browse/abroad",
          "count" => 4,
        },
        {
          "path" => "/browse/benefits",
          "count" => 2,
        },
        {
          "path" => "/browse/tax",
          "count" => 3,
        },
      ])
      expect(json_response).to include(
        "total_count" => 3,
        "current_page" => 1,
        "pages" => 1,
        "page_size" => 100,
      )
    end
  end

  context "with pagination" do
    it "returns the correct figures for 2018-02-21 1st page" do
      get_json "/feedback-by-day/2018-02-21?page=1&per_page=2"
      expect(response.status).to eq(200)
      expect(json_response["results"]).to eq([
        {
          "path" => "/browse/abroad",
          "count" => 5,
        },
        {
          "path" => "/browse/benefits",
          "count" => 6,
        },
      ])
      expect(json_response).to include(
        "total_count" => 3,
        "current_page" => 1,
        "pages" => 2,
        "page_size" => 2,
      )
    end

    it "returns the correct figures for 2018-02-21 2nd page" do
      get_json "/feedback-by-day/2018-02-21?page=2&per_page=2"
      expect(response.status).to eq(200)
      expect(json_response["results"]).to eq([
        {
          "path" => "/browse/tax",
          "count" => 8,
        },
      ])
      expect(json_response).to include(
        "total_count" => 3,
        "current_page" => 2,
        "pages" => 2,
        "page_size" => 2,
      )
    end
  end

  context "when the user is not authenticated" do
    around do |example|
      ClimateControl.modify(GDS_SSO_MOCK_INVALID: "1") { example.run }
    end

    it "returns an unauthorized response" do
      get "/feedback-by-day/2018-02-21"
      expect(response).to be_unauthorized
    end
  end
end
