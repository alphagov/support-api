require "rails_helper"

describe AnonymousFeedbackController, type: :controller do
  describe "#index" do
    before { login_as_stub_user }

    describe "backwards compatibility for `path_prefix` param" do
      before do
        create(:anonymous_contact, path: "/tax-disc")
      end

      it "is a bad request with no `path_prefixes` or `organisation_slug`" do
        get :index
        expect(response).to have_http_status(400)
      end

      it "is backwards compatible with valid `path_prefix`" do
        get :index, params: { path_prefix: "/tax-disc" }
        expect(response).to be_successful
      end

      it "is backwards compatible and returns an empty result when single path is provided" do
        get :index, params: { path_prefix: "/non-existent" }

        expect(response).to be_successful
        expect(json_response).to eq(
          "results" => [],
          "page_size" => 50,
          "total_count" => 0,
          "current_page" => 1,
          "pages" => 0,
        )
      end

      it "is backwards compatible and returns an empty result if the user has gone beyond the last page for a single path" do
        get :index, params: { path_prefix: "/tax-disc", page: 2 }

        expect(json_response).to eq(
          "results" => [],
          "page_size" => 50,
          "total_count" => 1,
          "current_page" => 2,
          "pages" => 1,
        )
      end
    end

    describe "it allows search by multiple path prefixes" do
      before do
        create_list(:anonymous_contact, 2, path: "/tax-disc")
        create_list(:anonymous_contact, 2, path: "/vat-rates")
      end

      it "is successful with valid `path_prefixes`" do
        get :index, params: { path_prefixes: ["/tax-disc", "/vat-rates"] }
        expect(response).to be_successful
        expect(json_response["results"].count).to eq(4)
        expect(json_response["page_size"]).to eq(50)
        expect(json_response["total_count"]).to eq(4)
        expect(json_response["current_page"]).to eq(1)
        expect(json_response["pages"]).to eq(1)
      end

      it "returns an empty result when no results are found" do
        get :index, params: { path_prefixes: ["/non-existent"] }

        expect(response).to be_successful
        expect(json_response).to eq(
          "results" => [],
          "page_size" => 50,
          "total_count" => 0,
          "current_page" => 1,
          "pages" => 0,
        )
      end

      it "returns results for the valid paths out of a list" do
        get :index, params: { path_prefixes: ["/non-existent", "/tax-disc", "/vat-rates"] }

        expect(response).to be_successful
        expect(json_response["results"].count).to eq(4)
        expect(json_response["page_size"]).to eq(50)
        expect(json_response["total_count"]).to eq(4)
        expect(json_response["current_page"]).to eq(1)
        expect(json_response["pages"]).to eq(1)
      end

      it "returns an empty result if the user has gone beyond the last page" do
        get :index, params: { path_prefixes: ["/tax-disc", "/vat-rates"], page: 2 }

        expect(json_response).to eq(
          "results" => [],
          "page_size" => 50,
          "total_count" => 4,
          "current_page" => 2,
          "pages" => 1,
        )
      end
    end

    describe "it allows search by document type" do
      it "is returns a successful result with any `document_type`" do
        create(:content_item, document_type: "smart_answer", path: "/calculate-your-holiday-entitlement")
        get :index, params: { document_type: "smart_answer" }
        expect(response).to be_successful
      end

      it "returns an empty result when no results are found" do
        get :index, params: { path_prefixes: ["/non-existent"] }

        expect(response).to be_successful
        expect(json_response).to eq(
          "results" => [],
          "page_size" => 50,
          "total_count" => 0,
          "current_page" => 1,
          "pages" => 0,
        )
      end
    end

    describe "limiting the page count" do
      before do
        create(:problem_report, path: "/tax-disc", what_doing: "First contact", what_wrong: "Nowt")
        create(:problem_report, path: "/tax-disc", what_doing: "Second contact", what_wrong: "Owt")
        create_list(:anonymous_contact, 98, path: "/tax-disc")
        create(:problem_report, path: "/tax-disc", what_doing: "Last contact", what_wrong: "Something")
        stub_const("AnonymousContact::MAX_PAGES", 2)
      end

      it "limits the counts to the max number of pages" do
        get :index, params: { path_prefixes: ["/tax-disc"], page: 1 }
        expect(json_response).to include(
          "page_size" => 50,
          "total_count" => 100,
          "current_page" => 1,
          "pages" => 2,
        )
        expect(json_response["results"][0]["what_doing"]).to eq("Last contact")
      end

      it "truncates at the max page count" do
        get :index, params: { path_prefixes: ["/tax-disc"], page: 2 }
        expect(json_response).to include(
          "page_size" => 50,
          "total_count" => 100,
          "current_page" => 2,
          "pages" => 2,
        )
        expect(json_response["results"].map { |r| r["what_doing"] }).to_not include("First contact")
        expect(json_response["results"].last["what_doing"]).to eq("Second contact")
      end

      it "doesn't show more than the max pages" do
        get :index, params: { path_prefixes: ["/tax-disc"], page: 3 }
        expect(json_response).to include(
          "page_size" => 50,
          "total_count" => 100,
          "current_page" => 3,
          "pages" => 2,
          "results" => [],
          "results_limited" => true,
        )
      end
    end

    describe "filter by organisation" do
      let(:hmrc) { create(:organisation, slug: "hm-revenue-customs") }
      let(:ukvi) { create(:organisation, slug: "uk-visas-and-immigration") }
      let(:ukvi_content) { create(:content_item, organisations: [ukvi]) }
      let(:hmrc_content) { create(:content_item, organisations: [hmrc]) }
      let!(:hmrc_problem_reports) { create_list(:problem_report, 3, path: "/abc", content_item: hmrc_content) }
      let!(:ukvi_problem_reports) { create_list(:problem_report, 2, content_item: ukvi_content) }

      it "returns only feedback belonging to that organisation" do
        get :index, params: { organisation_slug: "hm-revenue-customs" }

        expect(json_response["total_count"]).to eq(3)
        ids_of_returned_problem_reports = json_response["results"].map { |r| r["id"] }.sort
        expect(ids_of_returned_problem_reports).to eq(hmrc_problem_reports.map(&:id).sort)
      end

      context "if an org doesn't exist" do
        before { get :index, params: { organisation_slug: "made-up-org" } }
        it "doesn't return an error" do
          expect(response).to have_http_status(200)
        end

        it "returns no results" do
          expect(json_response["total_count"]).to eq(0)
          expect(json_response["results"]).to be_empty
        end
      end

      it "combines with path filters" do
        create(:problem_report, path: "/xyz", content_item: hmrc_content)

        get :index, params: { organisation_slug: "hm-revenue-customs", path_prefixes: ["/xyz"] }

        expect(json_response["total_count"]).to eq(1)
        expect(json_response["results"].first["path"]).to eq("/xyz")
      end
    end

    describe "filter by document type" do
      let(:hmrc) { create(:organisation, slug: "hm-revenue-customs") }
      let(:smart_answer) do
        create(
          :content_item,
          document_type: "smart_answer",
          path: "/calculate-your-holiday-entitlement",
          organisations: [hmrc],
        )
      end
      let(:case_study) { create(:content_item, document_type: "case_study", path: "/government/case-studies/out-of-syria-back-into-school") }
      let!(:sa_problem_report) { create(:problem_report, path: "/xyz", content_item: smart_answer) }
      let!(:cs_problem_reports) { create_list(:problem_report, 2, content_item: case_study) }

      it "returns only feedback belonging to the smart_answer" do
        get :index, params: { document_type: "smart_answer" }
        expect(json_response["total_count"]).to eq(1)
        ids_of_returned_problem_reports = json_response["results"].map { |r| r["id"] }.sort
        expect(ids_of_returned_problem_reports).to eq([sa_problem_report.id])
      end

      context "if a document type doesn't exist" do
        before { get :index, params: { document_type: "made-up-document-type" } }
        it "doesn't return an error" do
          expect(response).to have_http_status(200)
        end

        it "returns no results" do
          expect(json_response["total_count"]).to eq(0)
          expect(json_response["results"]).to be_empty
        end
      end

      it "combines with path filters" do
        get :index, params: { document_type: "smart_answer", path_prefixes: ["/xyz"] }

        expect(json_response["total_count"]).to eq(1)
        expect(json_response["results"].first["path"]).to eq("/xyz")
      end

      it "combines with organisation slug and" do
        get :index, params: { document_type: "smart_answer", organisation_slug: "hm-revenue-customs" }

        expect(json_response["total_count"]).to eq(1)
        expect(json_response["results"].first["path"]).to eq("/xyz")
      end
    end

    describe "from and to parameters" do
      let(:first_date)  { Time.zone.local(2014, 0o1, 0o1).utc }
      let(:second_date) { Time.zone.local(2014, 10, 31).utc }
      let(:third_date)  { Time.zone.local(2014, 11, 25).utc }
      let(:last_date)   { Time.zone.local(2014, 12, 12).utc }
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
          get :index, params: { path_prefixes: ["/"], from: from, to: to }

          expect(json_response).to eq(
            "results" => JSON.parse([@newest_contact, @third_contact, @second_contact, @first_contact].to_json),
            "page_size" => 50,
            "total_count" => 4,
            "current_page" => 1,
            "pages" => 1,
          )
        end
      end

      context "human readable dates for 'from' and 'to'" do
        let(:from)  { "13/10/2014" }
        let(:to)    { "1st December 2014" }

        it "returns relevant contacts" do
          get :index, params: { path_prefixes: ["/"], from: from, to: to }

          expect(json_response).to eq(
            "results" => JSON.parse([@third_contact, @second_contact].to_json),
            "from_date" => "2014-10-13",
            "to_date" => "2014-12-01",
            "page_size" => 50,
            "total_count" => 2,
            "current_page" => 1,
            "pages" => 1,
          )
        end
      end

      context "only 'from' date specified" do
        let(:from)  { "13/10/2014" }

        it "returns relevant contacts" do
          get :index, params: { path_prefixes: ["/"], from: from, to: to }

          expect(json_response).to eq(
            "results" => JSON.parse([@newest_contact, @third_contact, @second_contact].to_json),
            "page_size" => 50,
            "total_count" => 3,
            "current_page" => 1,
            "pages" => 1,
            "from_date" => "2014-10-13",
          )
        end
      end

      context "only 'to' date specified" do
        let(:to) { "1st December 2014" }

        it "returns relevant contacts" do
          get :index, params: { path_prefixes: ["/"], from: from, to: to }

          expect(json_response).to eq(
            "results" => JSON.parse([@third_contact, @second_contact, @first_contact].to_json),
            "page_size" => 50,
            "total_count" => 3,
            "current_page" => 1,
            "pages" => 1,
            "to_date" => "2014-12-01",
          )
        end
      end

      context "dates entered in non-chronological order" do
        let(:to) { "13th December 2014" }
        let(:from) { "24/11/2014" }

        it "returns relevant contacts" do
          get :index, params: { path_prefixes: ["/"], from: from, to: to }

          expect(json_response).to eq(
            "results" => JSON.parse([@newest_contact, @third_contact].to_json),
            "page_size" => 50,
            "total_count" => 2,
            "current_page" => 1,
            "pages" => 1,
            "to_date" => "2014-12-13",
            "from_date" => "2014-11-24",
          )
        end
      end
    end

    context "when using POST as the HTTP method" do
      context "with an existing content item" do
        let(:content_item) do
          create(:content_item, document_type: "smart_answer", path: "/calculate-your-holiday-entitlement")
        end

        before do
          create(:problem_report, content_item: content_item)
        end

        it "returns the content item in the results when searching for it" do
          post :index, params: { document_type: "smart_answer" }

          expect(response).to be_successful
          expect(json_response["total_count"]).to eq(1)
        end

        it "returns an empty result when no searching for something else" do
          post :index, params: { path_prefixes: ["/non-existent"] }

          expect(response).to be_successful
          expect(json_response).to eq(
            "results" => [],
            "page_size" => 50,
            "total_count" => 0,
            "current_page" => 1,
            "pages" => 0,
          )
        end
      end
    end
  end
end
