require "rails_helper"
require "distributed_lock"

describe DistributedLock do
  describe ".lock" do
    context "when it runs successfully" do
      it "returns the block value" do
        result = described_class.new("lock_name").lock { :complete }
        expect(result).to eq(:complete)
      end
    end

    context "when it fails to acquire a lock within the timeout" do
      before do
        allow(Redis.new).to receive(:lock) do
          raise Redis::Lock::LockNotAcquired
        end
      end

      it "supresses the exception and logs a debug message" do
        run = -> { described_class.new("lock_name").lock { :complete } }

        expect(Rails.logger).to receive(:debug)
        expect { run.call }.to_not raise_error
      end
    end
  end
end
