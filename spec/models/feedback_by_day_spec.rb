require 'rails_helper'
require 'feedback_by_day'

describe FeedbackByDay do
  before :each do
    create_list(:problem_report, 5, path: '/browse/abroad', created_at: Time.utc(2018, 02, 1, 0, 1, 0))
    create_list(:problem_report, 4, path: '/browse/abroad', created_at: Time.utc(2018, 02, 2))
    create_list(:problem_report, 6, path: '/browse/benefits', created_at: Time.utc(2018, 02, 1, 23, 59, 59))
    create_list(:problem_report, 2, path: '/browse/benefits', created_at: Time.utc(2018, 02, 2))
    create_list(:problem_report, 8, path: '/browse/tax', created_at: Time.utc(2018, 02, 1))
    create_list(:problem_report, 3, path: '/browse/tax', created_at: Time.utc(2018, 02, 2))
  end

  it "returns the correct data for 1st Feb" do
    expected = [
      {path: '/browse/abroad', count: 5},
      {path: '/browse/benefits', count:6},
      {path: '/browse/tax', count: 8}
    ]
    expect(FeedbackByDay.retrieve(Time.utc(2018, 2, 1))).to eq expected
  end

  it "returns the correct data for 2nd Feb" do
    expected = [
      {path: '/browse/abroad', count: 5},
      {path: '/browse/benefits', count:6},
      {path: '/browse/tax', count: 8}
    ]
    expect(FeedbackByDay.retrieve(Time.utc(2018, 2, 1))).to eq expected
  end

end
