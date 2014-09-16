require 'rails_helper'
require 'support/requests/anonymous/long_form_contact'

module Support
  module Requests
    module Anonymous
      describe LongFormContact do
        it { should validate_presence_of(:details) }
        it { should ensure_length_of(:user_specified_url).is_at_most(2048) }
        it { should ensure_length_of(:details).is_at_most(2**16) }
      end
    end
  end
end
