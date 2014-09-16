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
      end
    end
  end
end
