module AuthenticationHelper
  module ControllerMixin
    def login_as_stub_user
      request.env["warden"] = double(
        authenticate!: true,
        authenticated?: true,
      )
    end
  end
end
