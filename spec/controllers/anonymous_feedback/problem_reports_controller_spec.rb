require "rails_helper"

module AnonymousFeedback
  describe ProblemReportsController, type: :controller do
    context "#totals" do
      before { login_as_stub_user }

      it "returns a 404 for invalid dates" do
        get :totals, params: { date: "9999-99-99" }
        expect(response.status).to eq(422)
      end
    end
  end
end
