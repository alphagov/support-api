require 'rails_helper'

RSpec.describe FeedbackExportRequest, type: :model do
  before { Timecop.travel(Time.new(2015, 6, 1)) }

  describe "setting defaults" do
    subject(:instance) { described_class.new(notification_email: "user@example.com") }

    before { instance.validate }

    it "defaults the filename" do
      expect(instance.filename).to eq "feedex_0000-00-00_2015-06-01.csv"
    end

    it "doesn't default the from date" do
      expect(instance.filters[:from]).to be_nil
    end

    it "defaults the to date to today" do
      expect(instance.filters[:to]).to eq Date.today
    end
  end

  describe "#generate_filename!" do
    let(:instance) do
      described_class.new(filters: {path_prefix: path_prefix,
                                    from: from,
                                    to: to })
    end
    let(:path_prefix) { "/" }
    let(:from) { nil }
    let(:to)   { nil }

    describe "the resulting filename" do
      before { instance.generate_filename! }
      subject(:filename) { instance.filename }

      context "with no dates set" do
        context "with a root path" do
          let(:path_prefix) { "/" }

          it { is_expected.to eq "feedex_0000-00-00_2015-06-01.csv" }
        end

        context "with a single-level path" do
          let(:path_prefix) { "/gov_and_stuff" }

          it { is_expected.to eq "feedex_0000-00-00_2015-06-01_gov_and_stuff.csv" }
        end

        context "with a multi-level path" do
          let(:path_prefix) { "/gov_and_stuff/news-and-features" }

          it { is_expected.to eq "feedex_0000-00-00_2015-06-01_gov_and_stuff_news-and-features.csv" }
        end
      end

      context "with a from date set" do
        let(:from) { Date.new(2015, 4, 1) }

        context "with a root path" do
          let(:path_prefix) { "/" }

          it { is_expected.to eq "feedex_2015-04-01_2015-06-01.csv" }
        end

        context "with a single-level path" do
          let(:path_prefix) { "/gov_and_stuff" }

          it { is_expected.to eq "feedex_2015-04-01_2015-06-01_gov_and_stuff.csv" }
        end

        context "with a multi-level path" do
          let(:path_prefix) { "/gov_and_stuff/news-and-features" }

          it { is_expected.to eq "feedex_2015-04-01_2015-06-01_gov_and_stuff_news-and-features.csv" }
        end
      end

      context "with a to date set" do
        let(:to) { Date.new(2015, 5, 1) }

        context "with a root path" do
          let(:path_prefix) { "/" }

          it { is_expected.to eq "feedex_0000-00-00_2015-05-01.csv" }
        end

        context "with a single-level path" do
          let(:path_prefix) { "/gov_and_stuff" }

          it { is_expected.to eq "feedex_0000-00-00_2015-05-01_gov_and_stuff.csv" }
        end

        context "with a multi-level path" do
          let(:path_prefix) { "/gov_and_stuff/news-and-features" }

          it { is_expected.to eq "feedex_0000-00-00_2015-05-01_gov_and_stuff_news-and-features.csv" }
        end
      end

      context "with both dates set" do
        let(:from) { Date.new(2015, 4, 1) }
        let(:to) { Date.new(2015, 5, 1) }

        context "with a root path" do
          let(:path_prefix) { "/" }

          it { is_expected.to eq "feedex_2015-04-01_2015-05-01.csv" }
        end

        context "with a single-level path" do
          let(:path_prefix) { "/gov_and_stuff" }

          it { is_expected.to eq "feedex_2015-04-01_2015-05-01_gov_and_stuff.csv" }
        end

        context "with a multi-level path" do
          let(:path_prefix) { "/gov_and_stuff/news-and-features" }

          it { is_expected.to eq "feedex_2015-04-01_2015-05-01_gov_and_stuff_news-and-features.csv" }
        end
      end
    end
  end

  describe "#results" do
    subject do
      described_class.new(filters: {from: Date.new(2015, 4),
                                    to: Date.new(2015, 5),
                                    path_prefix: "/"}).results
    end

    it "uses the scope from the model with the correct parameters" do
      contact = double("AnonymousContact")
      expect(AnonymousContact).to receive(:for_query_parameters).with(from: Date.new(2015, 4),
                                                                      to: Date.new(2015, 5),
                                                                      path_prefix: "/").
        and_return(double("scope", most_recent_last: [contact]))

      expect(subject).to eq [contact]
    end
  end

  describe "#generate_csv" do
    before do
      create(:anonymous_contact, path: "/",
                                 created_at: Time.utc(2015, 6, 1, 10),
                                 referrer: "http://www.example.com/")
      create(:anonymous_contact, path: "/gov", created_at: Time.utc(2015, 6, 1, 20))
    end

    let(:io) { StringIO.new }

    subject(:generate_csv) { described_class.new.generate_csv(io) }

    it "has 2 records plus a header" do
      expect(subject.string.each_line.count).to eq 3
    end

    it "is parseable as a CSV" do
      expect(CSV.parse(subject.string).count).to eq 3
    end

    it "doesn't close the IO object" do
      expect(subject).to_not be_closed
    end

    it "uses the FeedbackCsvRowPresenter to format the row" do
      header = "creation date,path or service name,feedback,service satisfaction rating,browser name,browser version,browser platform,user agent,referrer,type"
      allow_any_instance_of(FeedbackCsvRowPresenter).to receive(:to_a).and_return(["a", "b", "c"])
      expect(subject.string).to eq "#{header}\na,b,c\na,b,c\n"
    end
  end
end
