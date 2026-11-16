require "rails_helper"
require "profanity_filter"

describe ProfanityFilter do
  describe ".mask" do
    it "masks texts with the vendored better-profanity and the pipeline wordlist" do
      expect(described_class.mask(["this page is shit", "all clean here", "sh1t happens"]))
        .to eq(["this page is ****", "all clean here", "**** happens"])
    end

    it "returns texts unchanged when they are empty" do
      expect(Open3).not_to receive(:capture2)
      expect(described_class.mask([])).to eq([])
    end
  end

  describe "failure policy (fail-open, never raises)" do
    it "returns the original texts when python is unavailable" do
      allow(ENV).to receive(:fetch).with("PROFANITY_PYTHON", "python3").and_return("/nonexistent/python")
      expect(GovukStatsd).to receive(:increment).with("govuk_zendesk.profanity_mask_error")

      expect(described_class.mask(["this page is shit"])).to eq(["this page is shit"])
    end

    it "returns the original texts when the script exits non-zero" do
      failing_status = instance_double(Process::Status, success?: false, exitstatus: 1)
      allow(Open3).to receive(:capture2).and_return(["", failing_status])
      expect(GovukStatsd).to receive(:increment).with("govuk_zendesk.profanity_mask_error")

      expect(described_class.mask(["this page is shit"])).to eq(["this page is shit"])
    end

    it "returns the original texts when the output is not valid JSON" do
      ok_status = instance_double(Process::Status, success?: true, exitstatus: 0)
      allow(Open3).to receive(:capture2).and_return(["<html>gateway error</html>", ok_status])
      expect(GovukStatsd).to receive(:increment).with("govuk_zendesk.profanity_mask_error")

      expect(described_class.mask(["this page is shit"])).to eq(["this page is shit"])
    end
  end
end
