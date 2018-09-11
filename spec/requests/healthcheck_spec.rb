require 'rails_helper'

describe "healthcheck path" do
  it "responds with 'OK'" do
    get "/healthcheck"
    expect(response).to be_successful
    expect(response.body).to eq("OK")
  end
end
