require 'rails_helper'

describe "/feedback-by-day endpoint" do
  before :each do
    create_list(:problem_report, 5, path: "/browse/abroad", created_at: Time.utc(2018, 02, 21))
    create_list(:problem_report, 4, path: "/browse/abroad", created_at: Time.utc(2018, 02, 22))
    create_list(:problem_report, 6, path: "/browse/benefits", created_at: Time.utc(2018, 02, 21))
    create_list(:problem_report, 2, path: "/browse/benefits", created_at: Time.utc(2018, 02, 22))
    create_list(:problem_report, 8, path: "/browse/tax", created_at: Time.utc(2018, 02, 21))
    create_list(:problem_report, 3, path: "/browse/tax", created_at: Time.utc(2018, 02, 22))
  end

  context 'with invalid requests' do
    it 'returns bad request for non date' do
      get_json "/feedback-by-day/blah"
      expect(response.status).to eq(400)
    end

    it 'returns bad request for invalid date' do
      get_json "/feedback-by-day/2018-02-31"
      expect(response.status).to eq(400)
    end
  end

  context 'with a valid request' do
    it 'returns the correct figures for 2018-02-21' do
      get_json "/feedback-by-day/2018-02-21"
      expect(response.status).to eq(200)
      expect(json_response["results"]).to eq([
        {
          'path' => '/browse/abroad',
          'count' => 5,
        },
        {
          'path' => '/browse/benefits',
          'count' => 6,
        },
        {
          'path' => '/browse/tax',
          'count' => 8
        }
      ])
    end

    it 'returns the correct figures for 2018-02-22' do
      get_json "/feedback-by-day/2018-02-22"
      expect(response.status).to eq(200)
      expect(json_response["results"]).to eq([
        {
          'path' => '/browse/abroad',
          'count' => 4,
        },
        {
          'path' => '/browse/benefits',
          'count' => 2,
        },
        {
          'path' => '/browse/tax',
          'count' => 3
        }
      ])
    end
  end
end
