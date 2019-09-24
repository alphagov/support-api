require "rails_helper"
require "feedback_by_day"

describe FeedbackByDay do
  before :each do
    create_list(:problem_report, 5, path: "/browse/abroad", created_at: Time.utc(2018, 2, 1, 0, 1, 0))
    create_list(:problem_report, 4, path: "/browse/abroad", created_at: Time.utc(2018, 2, 2))
    create_list(:problem_report, 6, path: "/browse/benefits", created_at: Time.utc(2018, 2, 1, 23, 59, 59))
    create_list(:problem_report, 2, path: "/browse/benefits", created_at: Time.utc(2018, 2, 2))
    create_list(:problem_report, 8, path: "/browse/tax", created_at: Time.utc(2018, 2, 1))
    create_list(:problem_report, 3, path: "/browse/tax", created_at: Time.utc(2018, 2, 2))
  end

  it "returns the correct data for 1st Feb" do
    expected = {
      results: [
        { path: "/browse/abroad", count: 5 },
        { path: "/browse/benefits", count: 6 },
        { path: "/browse/tax", count: 8 }
      ],
      total_count: 3,
      current_page: 1,
      pages: 1,
      page_size: 100
    }
    expect(FeedbackByDay.retrieve(Time.utc(2018, 2, 1), nil, nil)).to eq expected
  end

  it "returns the correct data for 2nd Feb" do
    expected = {
      results: [
        { path: "/browse/abroad", count: 5 },
        { path: "/browse/benefits", count: 6 },
        { path: "/browse/tax", count: 8 }
      ],
      total_count: 3,
      current_page: 1,
      pages: 1,
      page_size: 100
    }
    expect(FeedbackByDay.retrieve(Time.utc(2018, 2, 1), nil, nil)).to eq expected
  end

  context "with pagination" do
    before :each do
      (1..153).each do |n|
        create(:problem_report, path: "/aaa/#{pad_number(n)}", created_at: Time.utc(2018, 2, 3))
      end
    end

    it "returns the correct data for the 1st page with default page size of 100" do
      expected = {
        results: (1..100).map { |n| create_entry n },
        total_count: 153,
        current_page: 1,
        pages: 2,
        page_size: 100
      }
      expect(FeedbackByDay.retrieve(Time.utc(2018, 2, 3), nil, nil)).to eq expected
    end

    it "returns the correct data for the 2nd page with default page size of 100" do
      expected = {
        results: (101..153).map { |n| create_entry n },
        total_count: 153,
        current_page: 2,
        pages: 2,
        page_size: 100
      }
      expect(FeedbackByDay.retrieve(Time.utc(2018, 2, 3), 2, nil)).to eq expected
    end

    it "returns the correct data with a for the 1st page with specified page size of 50" do
      expected = {
        results: (1..50).map { |n| create_entry n },
        total_count: 153,
        current_page: 1,
        pages: 4,
        page_size: 50
      }
      expect(FeedbackByDay.retrieve(Time.utc(2018, 2, 3), 1, 50)).to eq expected
    end

    it "returns the correct data with a for the last page with specified page size of 50" do
      expected = {
        results: (151..153).map { |n| create_entry n },
        total_count: 153,
        current_page: 4,
        pages: 4,
        page_size: 50
      }
      expect(FeedbackByDay.retrieve(Time.utc(2018, 2, 3), 4, 50)).to eq expected
    end
  end

  def create_entry(n)
    { path: "/aaa/#{pad_number(n)}", count: 1 }
  end

  def pad_number(n)
    n.to_s.rjust(3, "0")
  end
end
