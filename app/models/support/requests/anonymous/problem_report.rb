require 'support/requests/anonymous/anonymous_contact'

module Support
  module Requests
    module Anonymous
      class ProblemReport < AnonymousContact
        validates :what_doing, length: { maximum: 2 ** 16 }
        validates :what_wrong, length: { maximum: 2 ** 16 }
      end
    end
  end
end
