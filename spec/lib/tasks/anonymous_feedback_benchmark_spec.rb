require "rails_helper"
require "csv"

describe "anonymous_feedback:benchmark" do
  subject(:task) { Rake::Task["anonymous_feedback:benchmark"] }

  let(:benchmark) { instance_double(AnonymousFeedbackBenchmark) }
  let(:path) { "anonymous_feedback_benchmark_my_label.csv" }
  let(:rows) { CSV.read(path, headers: true) }
  let(:stats) { { live_tuples: 3, dead_tuples: 0, heap_bytes: 2_097_152 } }
  let(:measurement) do
    {
      label: "my_label",
      params: "paths=/a",
      query: "count",
      run: 1,
      execution: 1.5,
      shared_hit: 10,
      shared_read: 0,
      scan: "Index Scan",
      **stats,
    }
  end

  before do
    task.reenable
    allow($stdout).to receive(:puts)
    allow(AnonymousFeedbackBenchmark).to receive(:new).and_return(benchmark)
    allow(benchmark).to receive(:wait_for_vacuums)
    allow(benchmark).to receive(:refresh_statistics)
    allow(benchmark).to receive(:table_stats).and_return(stats)
    allow(benchmark).to receive(:run).and_return([measurement, measurement.merge(run: 2)])
  end

  after { FileUtils.rm_f(path) }

  it "explains how to name the run when no label is given" do
    expect { task.invoke }
      .to raise_error(SystemExit)
      .and output(/usage: bundle exec rake "anonymous_feedback:benchmark\[my_label\]"/).to_stderr
  end

  it "refreshes the table statistics before measuring" do
    task.invoke("my_label")

    expect(benchmark).to have_received(:refresh_statistics).ordered
    expect(benchmark).to have_received(:run).ordered
  end

  it "writes a CSV named after the run" do
    task.invoke("my_label")

    expect(File).to exist(path)
  end

  it "writes one row per measurement" do
    task.invoke("my_label")

    expect(rows.size).to eq(2)
  end

  it "writes each measurement's values under the column headings" do
    task.invoke("my_label")

    expect(rows.first.to_h).to include("query" => "count", "scan" => "Index Scan", "run" => "1")
  end

  it "reports where it wrote the measurements" do
    task.invoke("my_label")

    expect($stdout).to have_received(:puts).with(a_string_including(path))
  end
end
