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

    describe "from and to parameters" do
      let(:first_date)  { Time.new(2014, 01, 01) }
      let(:second_date) { Time.new(2014, 10, 31) }
      let(:third_date)  { Time.new(2014, 11, 25) }
      let(:last_date)   { Time.new(2014, 12, 12) }
      let(:request)     { get :index, path_prefix: "/", from: from, to: to }
      let(:from)        { nil }
      let(:to)          { nil }

      before do
        @first_contact = create(:anonymous_contact, created_at: first_date).reload
        @second_contact = create(:anonymous_contact, created_at: second_date).reload
        @third_contact = create(:anonymous_contact, created_at: third_date).reload
        @newest_contact = create(:anonymous_contact, created_at: last_date).reload
      end

      context "when no to and from dates specified" do
        it "should return all the contacts" do
          request

          expect(json_response).to eq(
            "results" =>JSON.parse([@newest_contact, @third_contact, @second_contact, @first_contact].to_json),
            "page_size" => 50,
            "total_count" => 4,
            "current_page" => 1,
            "pages" => 1,
          )
        end
      end

      context "human readable dates for 'from' and 'to'" do
        let(:from)  {"13/10/2014"}
        let(:to)    {"1st December 2014"}

        it "returns relevant contacts" do
          request

          expect(json_response).to eq(
            "results" =>JSON.parse([@third_contact, @second_contact].to_json),
            "page_size" => 50,
            "total_count" => 2,
            "current_page" => 1,
            "pages" => 1,
          )
        end
      end

      context "only 'from' date specified" do
        let(:from)  {"13/10/2014"}

        it "returns relevant contacts" do
          request

          expect(json_response).to eq(
            "results" =>JSON.parse([@newest_contact, @third_contact, @second_contact].to_json),
            "page_size" => 50,
            "total_count" => 3,
            "current_page" => 1,
            "pages" => 1,
          )
        end
      end

      context "only 'to' date specified" do
        let(:to)  {"1st December 2014"}

        it "returns relevant contacts" do
          request

          expect(json_response).to eq(
            "results" =>JSON.parse([@third_contact, @second_contact, @first_contact].to_json),
            "page_size" => 50,
            "total_count" => 3,
            "current_page" => 1,
            "pages" => 1,
          )
        end
      end
    end
  end

  describe "parse_date" do
    subject() { described_class.new.parse_date(input) }

    context "with a valid short form date" do
      let(:input) {"13/10/2014"}
      it {is_expected.to eq(Time.new(2014, 10, 13))}
    end

    context "with a valid long form date" do
      let(:input) {"1st December 2014"}
      it {is_expected.to eq(Time.new(2014, 12, 1))}
    end
    context "with a nil date" do
      let(:input) { nil }
      it {is_expected.to be_nil}
    end

    context "with an invalid date" do
      let(:input) {"foo"}
      it {is_expected.to be_nil}
    end

  end
end
