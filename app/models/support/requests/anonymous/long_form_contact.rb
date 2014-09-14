require 'support/requests/anonymous/anonymous_contact'

module Support
  module Requests
    module Anonymous
      class LongFormContact < AnonymousContact
        validates_presence_of :details
        validates :user_specified_url, length: { maximum: 2048 }
        validates :details, length: { maximum: 2 ** 16 }
      end
    end
  end
end
