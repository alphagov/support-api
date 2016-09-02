require 'rails_helper'
require 'problem_report_list'

describe ProblemReportList, '#to_json' do
  let(:what_wrong) { "Help" }
  let(:what_doing) { "Skiing" }
  let(:path)       { "/help" }
  let(:referrer)   { "https://www.gov.uk/browse" }
  let(:user_agent) { "Safari" }
  let(:created_at) { Date.new(2015, 02, 02) }

  let!(:problem_report) {
    create(:problem_report,
           what_wrong: what_wrong,
           what_doing: what_doing,
           path: path,
           referrer: referrer,
           user_agent: user_agent,
           created_at: created_at,
           reviewed: false
          )
  }

  context 'returns JSON structure' do
    let(:from_date) { created_at - 1.week }
    let(:to_date) { created_at + 1.week }

    let(:expected_report_json) {
      {
        "id" => problem_report.id,
        "type" => "problem-report",
        "what_wrong" => what_wrong,
        "what_doing" => what_doing,
        "url" => "http://www.dev.gov.uk#{path}",
        "referrer" => referrer,
        "user_agent" => user_agent,
        "path" => path,
        "marked_as_spam" => false
      }
    }

    let(:expected_metadata) {
      {
        "total_count" => 1,
        "current_page" => 1,
        "pages" => 1,
        "page_size" => AnonymousContact::PAGE_SIZE,
        "from_date" => "#{from_date.to_s}",
        "to_date" => "#{to_date.to_s}"
      }
    }

    let(:json) { JSON.parse(described_class.new({from_date: from_date.to_s, to_date: to_date.to_s}).to_json) }

    it 'returns JSON representations of problem reports' do
      expect(json["results"].first).to include(expected_report_json)
    end

    it 'returns metadata about the results' do
      expect(json).to include expected_metadata
    end
  end

  context 'when supplied with no parameters' do
    let!(:earlier_problem_report) { create :problem_report, created_at: created_at - 1.day }

    before do
      stub_const("AnonymousContact::PAGE_SIZE", 2)
    end

    it 'returns all reports' do
      json = JSON.parse(described_class.new({}).to_json)

      expect(json["results"].length).to eq 2

      expect(json["results"][0]).to include({ "id" => problem_report.id })
      expect(json["results"][1]).to include({ "id" => earlier_problem_report.id })
    end
  end

  context 'pagination' do
    let!(:earlier_problem_report) { create :problem_report, created_at: created_at - 1.day }

    before do
      stub_const("AnonymousContact::PAGE_SIZE", 1)
    end

    context 'when supplied with no parameters' do
      it 'returns the first page of problem reports' do
        json = JSON.parse(described_class.new({}).to_json)

        expect(json["current_page"]).to eq 1

        expect(json["results"].length).to eq 1
        expect(json["results"].first.values).to include problem_report.id
      end
    end

    context 'when supplied with a page number parameter' do
      it 'returns results for that particular page' do
        json = JSON(described_class.new({page: 2}).to_json)

        expect(json["current_page"]).to eq 2
        expect(json["results"].length).to eq 1

        expect(json["results"].first.values).to include earlier_problem_report.id
      end
    end
  end

  context 'results scoped to dates' do
    let!(:earlier_problem_report) { create :problem_report, created_at: created_at - 1.day }
    let!(:later_problem_report) { create :problem_report, created_at: created_at + 1.week + 2.day }

    context 'when supplied with start and end date parameters' do
      let(:from_date) { created_at - 1.week }
      let(:to_date) { created_at + 1.week }

      it 'returns problem reports that are scoped to the dates' do
        json = JSON.parse(described_class.new({from_date: from_date.to_s, to_date: to_date.to_s}).to_json)

        expect(json["results"].length).to eq 2

        expect(json["results"][0]).to include({ "id" => problem_report.id })
        expect(json["results"][1]).to include({ "id" => earlier_problem_report.id })
      end
    end

    context 'when supplied with a start date parameter' do
      it 'returns problem reports from that date until today' do
        json = JSON.parse(described_class.new({from_date: created_at.to_s}).to_json)

        expect(json["results"].length).to eq 2

        expect(json["results"][0]).to include({ "id" => later_problem_report.id })
        expect(json["results"][1]).to include({ "id" => problem_report.id })
      end
    end
  end

  context 'when no parameters are supplied' do
    let!(:reviewed_report) { create :problem_report, reviewed: true}

    it 'returns problem reports that are not marked as reviewed only' do
      json = JSON.parse(described_class.new({}).to_json)

      expect(json["results"].length).to eq 1
      expect(json["results"].first.values).to include problem_report.id
    end
  end

  context 'with a full set of filter parameters supplied' do
    let!(:earliest_problem_report_unreviewed) { create :problem_report, created_at: created_at - 2.weeks }
    let!(:earlier_problem_report_reviewed) { create :problem_report, created_at: created_at - 2.days, reviewed: true }
    let!(:later_problem_report_reviewed) { create :problem_report, created_at: created_at + 1.day, reviewed: true }
    let!(:later_problem_report_unreviewed) { create :problem_report, created_at: created_at + 1.day }

    let(:from_date) { created_at - 1.week }
    let(:to_date) { created_at + 1.day }

    before do
      stub_const("AnonymousContact::PAGE_SIZE", 2)
    end

    it 'returns problem reports that fulfil those filters exactly' do
      json = JSON.parse(described_class.new({from_date: from_date.to_s, to_date: to_date.to_s, include_reviewed: true, page: 2}).to_json)

      expect(json["results"].length).to eq 2
      expect(json["results"].first.values).to include problem_report.id
      expect(json["results"].second.values).to include earlier_problem_report_reviewed.id
    end
  end
end
