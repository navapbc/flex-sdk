# frozen_string_literal: true

require "rails_helper"

RSpec.describe ActiveJobRun, type: :model do
  before do
    stub_const("TrackedTestJob", Class.new(ActiveJob::Base) do
      def perform(value)
        raise "demonstration failure" if value == "fail"

        value.upcase
      end
    end)
  end

  it "records a successful ActiveJob execution" do
    result = nil

    expect {
      result = TrackedTestJob.perform_now("passport")
    }.to change(described_class, :count).by(1)

    expect(result).to eq("PASSPORT")
    expect(described_class.last).to have_attributes(
      job_class: "TrackedTestJob",
      queue_name: "default",
      status: "succeeded",
      executions: 1,
      arguments: [ "passport" ],
      error_class: nil,
      error_message: nil
    )
    expect(described_class.last.finished_at).to be_present
    expect(described_class.last.duration_ms).to be >= 0
  end

  it "records a failed execution without swallowing the job error" do
    expect {
      TrackedTestJob.perform_now("fail")
    }.to raise_error(RuntimeError, "demonstration failure")
      .and change(described_class, :count).by(1)

    expect(described_class.last).to have_attributes(
      job_class: "TrackedTestJob",
      status: "failed",
      error_class: "RuntimeError",
      error_message: "demonstration failure"
    )
    expect(described_class.last.finished_at).to be_present
  end

  it "records repeated executions of the same job separately" do
    job = TrackedTestJob.new("passport")

    expect {
      job.perform_now
      job.perform_now
    }.to change(described_class, :count).by(2)

    expect(described_class.where(job_id: job.job_id).order(:executions).pluck(:executions, :status)).to eq([
      [ 1, "succeeded" ],
      [ 2, "succeeded" ]
    ])
  end
end
