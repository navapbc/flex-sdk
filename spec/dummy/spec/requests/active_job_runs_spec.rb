# frozen_string_literal: true

require "rails_helper"

RSpec.describe "ActiveJob run history", type: :request do
  it "lists executed jobs and their diagnostics" do
    ActiveJobRun.create!(
      job_id: "job-123",
      job_class: "Strata::Events::DispatchJob",
      queue_name: "default",
      status: "succeeded",
      executions: 2,
      arguments: [ "event-456" ],
      enqueued_at: 2.seconds.ago,
      started_at: 1.second.ago,
      finished_at: Time.current,
      duration_ms: 8
    )

    get active_job_runs_path

    expect(response).to have_http_status(:success)
    expect(response.body).to include("ActiveJob run history")
    expect(response.body).to include("usa-breadcrumb__list")
    expect(response.body).to include("Strata::Events::DispatchJob")
    expect(response.body).to include("job-123")
    expect(response.body).to include("event-456")
    expect(response.body).to include("Succeeded")
    expect(response.body).to include("execution 2")
    expect(response.body).to include("Strata dispatcher")
    expect(response.body).to include("Queue adapter")
  end

  it "shows guidance when no jobs have run" do
    get active_job_runs_path

    expect(response).to have_http_status(:success)
    expect(response.body).to include("No jobs have run yet")
    expect(response.body).to include("Open passport process")
  end
end
