require 'rails_helper'

describe AnonymousContact, :type => :model do
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
    it "can find urls beginning with the given path" do
      a = contact(path: "/some-calculator/y/abc")
      b = contact(path: "/some-calculator/y/abc/x")
      c = contact(path: "/tax-disc")

      result = AnonymousContact.matching_path_prefix("/some-calculator")

      expect(result).to contain_exactly(a, b)
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

    describe "created_between" do
      let(:first_date) { Time.new(2014, 01, 01) }
      let(:second_date) { Time.new(2014, 10, 31) }
      let(:third_date){ Time.new(2014, 11, 25) }
      let(:last_date) { Time.new(2014, 12, 12) }

      before do
        @first_contact = new_contact(created_at: first_date)
        @second_contact = new_contact(created_at: second_date)
        @third_contact = new_contact(created_at: third_date)
        @newest_contact = new_contact(created_at: last_date)
        @first_contact.save!
        @second_contact.save!
        @third_contact.save!
        @newest_contact.save!
      end

      it "returns the items that are included in the date interval" do
        expect(AnonymousContact.created_between(second_date, last_date).sort).to eq([@second_contact, @third_contact, @newest_contact])
      end

      it "accepts an open date range for the first date" do
        expect(AnonymousContact.created_between(nil, second_date).sort).to eq([@first_contact, @second_contact])
      end

      it "accepts an open date range for the last date" do
        expect(AnonymousContact.created_between(second_date, nil).sort).to eq([@second_contact, @third_contact, @newest_contact])
      end

      it "returns all the items when no date range has been selected" do
        expect(AnonymousContact.created_between(nil, nil).sort).to eq([@first_contact, @second_contact, @third_contact, @newest_contact])
      end

    end
  end

  describe "pagination" do
    it "returns maximum of 50 results" do
      create_list(:anonymous_contact, 70)
      expect(AnonymousContact.page(1).count).to eq(50)
    end
  end
end
