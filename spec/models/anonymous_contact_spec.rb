require "rails_helper"

describe AnonymousContact, type: :model do
  def new_contact(options = {})
    build(:anonymous_contact, options)
  end

  def contact(options = {})
    create(:anonymous_contact, options)
  end

  it "enforces the presence of a reason why feedback isn't actionable" do
    contact = new_contact(is_actionable: false, reason_why_not_actionable: "")
    expect(contact).to_not be_valid
    expect(contact).to have_at_least(1).error_on(:reason_why_not_actionable)
  end

  it "doesn't detect personal info when none is present in free text fields" do
    expect(contact(details: "abc", what_wrong: "abc", what_doing: "abc").personal_information_status).to eq("absent")
  end

  it "notices when an email is present in one of the free text fields" do
    expect(contact(details: "contact me at name@domain.com please").personal_information_status).to eq("suspected")
    expect(contact(what_doing: "contact me at name@domain.com please").personal_information_status).to eq("suspected")
    expect(contact(what_wrong: "contact me at name@domain.com please").personal_information_status).to eq("suspected")
  end

  it "notices when a national insurance number is present in one of the free text fields" do
    expect(contact(details: "my NI number is QQ 12 34 56 A thanks").personal_information_status).to eq("suspected")
    expect(contact(what_doing: "my NI number is QQ 12 34 56 A thanks").personal_information_status).to eq("suspected")
    expect(contact(what_wrong: "my NI number is QQ 12 34 56 A thanks").personal_information_status).to eq("suspected")
  end

  it "validates the personal_information_status field" do
    expect(new_contact(personal_information_status: nil)).to be_valid
    expect(new_contact(personal_information_status: "suspected")).to be_valid
    expect(new_contact(personal_information_status: "absent")).to be_valid

    expect(new_contact(personal_information_status: "abcde")).to_not be_valid
  end

  context "URLs" do
    it "should be derived from the path" do
      expect(new_contact(path: "/vat-rates").url).to eq("http://www.dev.gov.uk/vat-rates")
    end
  end

  context "path" do
    it { should allow_value("/something").for(:path) }
    it { should allow_value("/" + ("a" * 2040)).for(:path) }
    it { should_not allow_value("").for(:path) }
    it { should_not allow_value("/" + ("a" * 2050)).for(:path) }
    it { should_not allow_value("/méh/fào?bar").for(:path) }
  end

  context "referrer" do
    it { should allow_value("https://www.gov.uk/y").for(:referrer) }
    it { should allow_value(nil).for(:referrer) }
    it { should allow_value("http://" + ("a" * 2040)).for(:referrer) }
    it { should_not allow_value("http://" + ("a" * 2050)).for(:referrer) }
    it { should_not allow_value("http://bla.example.org:9292/méh/fào?bar").for(:referrer) }
    it { should allow_value("android-app://com.google.android.googlequicksearchbox").for(:referrer) }
  end

  context "when duplicates are present" do
    let(:current_time) { Time.now }
    let(:dedupe_interval) { (current_time - 1.second)..(current_time + 5.seconds) }

    let!(:first) { create(:service_feedback, created_at: current_time) }
    let!(:second) { create(:service_feedback, created_at: current_time + 3.seconds) }

    it "marks the dupes as non-actionable when deduplication is run" do
      AnonymousContact.deduplicate_contacts_created_between(dedupe_interval)

      first.reload
      second.reload

      expect(first.is_actionable).to be_truthy
      expect(second.is_actionable).to be_falsey
      expect(second.reason_why_not_actionable).to eq("duplicate")
    end
  end

  context "scopes" do
    describe "for_document_type" do
      let!(:sa_content_items) { create_list(:content_item, 2, document_type: "smart_answer") }
      let!(:cs_content_items) { create_list(:content_item, 3, document_type: "case_study") }
      let!(:sa_contact1) { contact(path: "/tax-disc", content_item: sa_content_items[0]) }
      let!(:sa_contact2) { contact(path: "/tax-disc2", content_item: sa_content_items[1]) }
      let!(:sa_contact3) { contact(path: "/tax-disc3") }
      let!(:cs_contact1) { contact(path: "/some-calculator1", content_item: cs_content_items[0]) }
      let!(:cs_contact2) { contact(path: "/some-calculator2", content_item: cs_content_items[1]) }
      let!(:cs_contact3) { contact(path: "/some-calculator3", content_item: cs_content_items[2]) }

      it "can find content contacts associated with smart answers" do
        result1 = AnonymousContact.for_document_type("smart_answer")
        result2 = AnonymousContact.for_document_type("case_study")

        expect(result1).to contain_exactly(sa_contact1, sa_contact2)
        expect(result2).to contain_exactly(cs_contact1, cs_contact2, cs_contact3)
      end
    end

    describe "matching_path_prefixes" do
      let!(:a) { contact(path: "/some-calculator/y/abc") }
      let!(:b) { contact(path: "/some-calculator/y/abc/x") }
      let!(:c) { contact(path: "/tax-disc") }

      it "can find urls beginning with the given paths" do
        result = AnonymousContact.matching_path_prefixes(["/some-calculator", "/tax-disc"])

        expect(result).to contain_exactly(a, b, c)
      end

      it "is a no-op when given a nil path" do
        result = AnonymousContact.matching_path_prefixes(nil)

        expect(result).to contain_exactly(a, b, c)
      end
    end

    it "can return the results in reverse chronological order" do
      a = contact(created_at: Time.now - 1.hour)
      b = contact(created_at: Time.now - 2.hour)
      c = contact(created_at: Time.now)

      expect(AnonymousContact.most_recent_first).to eq([c, a, b])
    end

    it "can filter reports with personal information" do
      a = contact(personal_information_status: "absent")
      contact(personal_information_status: "suspected")

      expect(AnonymousContact.free_of_personal_info).to eq([a])
    end

    it "can return only actionable feedback" do
      a = contact(is_actionable: true)
      contact(is_actionable: false, reason_why_not_actionable: "spam")

      expect(AnonymousContact.only_actionable).to eq([a])
    end

    describe "created_between_days" do
      let(:first_date) { Time.new(2014, 0o1, 0o1) }
      let(:second_date) { Time.new(2014, 10, 31) }
      let(:third_date) { Time.new(2014, 11, 25) }
      let(:last_date) { Time.new(2014, 12, 12) }

      before do
        @first_contact = contact(created_at: first_date)
        @second_contact = contact(created_at: second_date)
        @third_contact = contact(created_at: third_date)
        @newest_contact = contact(created_at: last_date + 12.hours)
      end

      it "returns the items that are included in the date interval" do
        expect(AnonymousContact.created_between_days(second_date.to_date, last_date.to_date).sort).to eq([@second_contact, @third_contact, @newest_contact])
      end
    end

    describe "for_query_parameters" do
      let!(:smart_answer) { create(:content_item, document_type: "smart_answer") }
      let!(:contact_1) { contact(path: "/gov", created_at: Time.new(2015, 4, 10), content_item: smart_answer) }
      let!(:contact_2) { contact(path: "/courts", created_at: Time.new(2015, 5, 10), content_item: smart_answer) }
      let!(:contact_3) { contact(path: "/courts", created_at: Time.new(2015, 5, 10)) }
      let!(:personal_info) { contact(path: "/gov", details: "foo@example.com") }
      let!(:not_actionable) { contact(path: "/gov", is_actionable: false, reason_why_not_actionable: "spam") }
      subject do
        described_class.for_query_parameters(
          path_prefixes: path_prefixes,
          from: from,
          to: to,
          document_type: document_type,
        ).sort
      end

      let(:path_prefixes) { nil }
      let(:from) { nil }
      let(:to)   { nil }
      let(:document_type) { nil }

      context "with no restrictions" do
        it { is_expected.to eq [contact_1, contact_2, contact_3].sort }
      end

      context "with a restrictive from date" do
        let(:from) { Date.new 2015, 5 }
        it { is_expected.to eq [contact_2, contact_3] }
      end

      context "with a restrictive to date" do
        let(:to) { Date.new 2015, 5 }
        it { is_expected.to eq [contact_1] }
      end

      context "with a restrictive date range" do
        let(:from) { Date.new 2015, 4 }
        let(:to) { Date.new 2015, 5 }

        it { is_expected.to eq [contact_1] }
      end

      context "with a restrictive path prefix" do
        let(:path_prefixes) { ["/gov"] }
        it { is_expected.to eq [contact_1] }
      end

      context "with a document type" do
        let(:document_type) { "smart_answer" }

        it { is_expected.to eq([contact_1, contact_2]) }
      end

      context "with a non-existent document type" do
        let(:document_type) { "made-up-document-type" }

        it { is_expected.to be_empty }
      end

      context "with a nil document type" do
        let(:document_type) { nil }

        it "returns all contacts associated or not with a content item" do
          expect(AnonymousContact.for_query_parameters(document_type: nil)).to include(contact_1)
          expect(AnonymousContact.for_query_parameters(document_type: nil)).to include(contact_2)
          expect(AnonymousContact.for_query_parameters(document_type: nil)).to include(contact_3)
        end
      end
    end
  end
end
