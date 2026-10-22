require "rails_helper"
require "anonymous_feedback_benchmark"

describe AnonymousFeedbackBenchmark do
  describe "#wait_for_vacuums" do
    let(:benchmark) { described_class.new([]) }
    let(:connection) { double("connection") }
    let(:waiting_for) { [] }

    before do
      allow(benchmark).to receive(:connection).and_return(connection)
      allow(benchmark).to receive(:sleep)
    end

    it "returns once no vacuum has been seen for three consecutive checks" do
      allow(connection).to receive(:select_value).and_return(0, 0, 0)

      benchmark.wait_for_vacuums { |count| waiting_for << count }

      expect(connection).to have_received(:select_value).exactly(3).times
    end

    it "starts counting again when a vacuum appears between checks" do
      allow(connection).to receive(:select_value).and_return(0, 0, 1, 0, 0, 0)

      benchmark.wait_for_vacuums { |count| waiting_for << count }

      expect(connection).to have_received(:select_value).exactly(6).times
    end

    it "reports how many vacuums it is waiting for" do
      allow(connection).to receive(:select_value).and_return(2, 0, 0, 0)

      benchmark.wait_for_vacuums { |count| waiting_for << count }

      expect(waiting_for).to eq([2])
    end
  end

  describe "#refresh_statistics" do
    it "analyses the table so the planner's statistics are current" do
      benchmark = described_class.new([])
      connection = double("connection")
      allow(benchmark).to receive(:connection).and_return(connection)
      allow(connection).to receive(:execute)

      benchmark.refresh_statistics

      expect(connection).to have_received(:execute).with("ANALYZE anonymous_contacts")
    end
  end

  describe "#table_stats" do
    it "reports the table's live rows, dead rows and size on disk" do
      expect(described_class.new([]).table_stats.keys)
        .to contain_exactly(:live_tuples, :dead_tuples, :heap_bytes)
    end
  end

  describe "#run" do
    subject(:rows) { benchmark.run("before", stats) { |row| measured << row } }

    let(:benchmark) { described_class.new([query_string], runs:) }
    let(:runs) { 1 }
    let(:measured) { [] }
    let(:stats) { { live_tuples: 1, dead_tuples: 0, heap_bytes: 8192 } }

    before { create(:problem_report, path: "/vat-rates") }

    context "with a query string matching some feedback" do
      let(:query_string) { "paths=/vat-rates" }

      it "measures the count and the first page" do
        expect(rows.map { |row| row[:query] }).to eq(["count", "page 1"])
      end

      it "records the label, query string and run number against each measurement" do
        expect(rows.first).to include(label: "before", params: query_string, run: 1)
      end

      it "records the table statistics it was given" do
        expect(rows.first).to include(stats)
      end

      it "records the timing, buffer counts and the node that read the table" do
        expect(rows.first.keys).to include(:execution, :shared_hit, :shared_read, :scan)
      end

      it "yields each measurement as it is taken" do
        expect(rows.size).to eq(measured.size)
      end
    end

    context "when the requested page is past the last page" do
      let(:query_string) { "paths=/vat-rates&page=2" }

      it "measures only the count, since the controller fetches no page" do
        expect(rows.map { |row| row[:query] }).to eq(%w[count])
      end
    end

    context "with more than one run of each query" do
      let(:query_string) { "paths=/vat-rates" }
      let(:runs) { 2 }

      it "numbers the runs within each query" do
        expect(rows.map { |row| row[:run] }).to eq([1, 2, 1, 2])
      end
    end
  end
end
