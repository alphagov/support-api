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
      expect(instance.filter_from).to be_nil
    end

    it "defaults the to date to today" do
      expect(instance.filter_to).to eq Date.today
    end
  end

  describe "#generate_filename!" do
    let(:instance) { described_class.new(path_prefix: path_prefix,
                                         filter_from: filter_from,
                                         filter_to: filter_to) }
    let(:path_prefix) { "/" }
    let(:filter_from) { nil }
    let(:filter_to)   { nil }

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
        let(:filter_from) { Date.new(2015, 4, 1) }

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
        let(:filter_to) { Date.new(2015, 5, 1) }

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
        let(:filter_from) { Date.new(2015, 4, 1) }
        let(:filter_to) { Date.new(2015, 5, 1) }

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
    subject { described_class.new(filter_from: Date.new(2015, 4),
                                  filter_to: Date.new(2015, 5),
                                  path_prefix: "/").results }

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

    it "has 2 records" do
      expect(subject.string.each_line.count).to eq 2
    end

    it "is parseable as a CSV" do
      expect(CSV.parse(subject.string).count).to eq 2
    end

    it "doesn't close the IO object" do
      expect(subject).to_not be_closed
    end

    describe "row format" do
      subject(:first_row) { CSV.parse(generate_csv.string)[0] }

      it "has the time in ISO8601 format in UTC as the first column" do
        expect(first_row[0]).to eq "2015-06-01 10:00:00"
      end

      it "has the path as the second column" do
        expect(first_row[1]).to eq "/"
      end

      it "has the referrer as the third column" do
        expect(first_row[2]).to eq "http://www.example.com/"
      end
    end
  end
end
