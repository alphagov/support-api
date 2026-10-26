require "rails_helper"

describe "config/initializers/gds_zendesk.rb" do
  around do |example|
    original = ENV["DISABLE_ZENDESK"]
    example.run
  ensure
    ENV["DISABLE_ZENDESK"] = original
  end

  def load_initializer
    # Hidden constants are restored after each example.
    %w[GDS_ZENDESK_URL ZENDESK_ANONYMOUS_TICKETS_REQUESTER_EMAIL GDS_ZENDESK_CLIENT].each { |name| hide_const(name) }
    load Rails.root.join("config/initializers/gds_zendesk.rb")
  end

  it "uses the real Zendesk client by default" do
    ENV.delete("DISABLE_ZENDESK")
    load_initializer

    expect(GDS_ZENDESK_CLIENT).to be_a(ZendeskAPI::Client)
  end

  it "uses the dummy client, which never contacts Zendesk, when DISABLE_ZENDESK is set" do
    ENV["DISABLE_ZENDESK"] = "1"
    load_initializer

    expect(GDS_ZENDESK_CLIENT).to be_a(Zendesk::DummyClient)
  end
end
