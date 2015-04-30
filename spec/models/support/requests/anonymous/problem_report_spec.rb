require 'rails_helper'
require 'support/requests/anonymous/problem_report'

module Support
  module Requests
    module Anonymous
      describe ProblemReport do
        it { should allow_value("abc").for(:what_doing) }
        it { should allow_value("abc").for(:what_wrong) }
        it { should allow_value("inside_government").for(:source) }
        it { should allow_value("hmrc").for(:page_owner) }

        it { should ensure_length_of(:what_doing).is_at_most(2**16) }
        it { should ensure_length_of(:what_wrong).is_at_most(2**16) }

        context "#totals" do
          let(:result) {
            ProblemReport.totals_for(Date.today).map { |r| { path: r.path, total: r.total } }
          }

          it "returns totals for a given day" do
            create(:problem_report, path: "/vat-rates")
            create_list(:problem_report, 2, path: "/student-finance-login")

            expect(result).to eq([
              { path: "/student-finance-login", total: 2 },
              { path: "/vat-rates", total: 1 }
            ])
          end
        end
      end
    end
  end
end
