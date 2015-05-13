require 'rails_helper'
require 'support/requests/anonymous/anonymous_contact'

class TestContact < Support::Requests::Anonymous::AnonymousContact; end

module Support
  module Requests
    module Anonymous
      describe AnonymousContact, :type => :model do
        DEFAULTS = { javascript_enabled: true, path: "/tax-disc" }

        def new_contact(options = {})
          TestContact.new(DEFAULTS.merge(options))
        end

        def contact(options = {})
          new_contact(options).tap { |c| c.save! }
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
      end
    end
  end
end
