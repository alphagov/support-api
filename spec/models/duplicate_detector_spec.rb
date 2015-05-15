require 'spec_helper'
require 'duplicate_detector'

describe DuplicateDetector do
  let(:current_time) { Time.now }

  let(:r1) { { "a" => "b", "created_at" => current_time } }
  let(:r2) { { "a" => "c", "created_at" => current_time } }
  let(:r3) { { "a" => "b", "created_at" => current_time } }

  subject { DuplicateDetector.new(["a"]) }

  it "identifies duplicate records" do
    expect(subject.duplicate?(r1)).to be_falsey
    expect(subject.duplicate?(r2)).to be_falsey
    expect(subject.duplicate?(r3)).to be_truthy
  end

  context "the comparator" do
    let(:comparator) { AnonymousFeedbackComparator.new(["a"]) }

    let(:r1) { { "a" => "b", "created_at" => current_time } }
    let(:r2) { r1.clone }
    let(:r3) { { "a" => "b", "created_at" => current_time + 4 } }
    let(:r4) { { "a" => "b", "created_at" => current_time + 8 } }

    it "detects if two identical pieces of feedback are created within a short time of each other" do
      expect(comparator.same?(r1, r2)).to be_truthy
      expect(comparator.same?(r1, r3)).to be_truthy
      expect(comparator.same?(r1, r4)).to be_falsey
      expect(comparator.same?(r3, r4)).to be_truthy
    end
  end
end
