# frozen_string_literal: true

class ActiveJobRun < ApplicationRecord
  STATUSES = %w[running succeeded failed].freeze

  validates :job_id, :job_class, :queue_name, :started_at, presence: true
  validates :executions, numericality: { only_integer: true, greater_than: 0 }
  validates :status, inclusion: { in: STATUSES }

  scope :recent_first, -> { order(started_at: :desc, created_at: :desc) }

  class << self
    def record_start(job)
      create!(
        job_id: job.job_id,
        job_class: job.class.name,
        queue_name: job.queue_name,
        status: "running",
        executions: job.executions,
        arguments: job.serialize.fetch("arguments"),
        enqueued_at: job.enqueued_at,
        started_at: Time.current
      )
    rescue StandardError => error
      Rails.logger.warn("ActiveJob run tracking could not start: #{error.class}: #{error.message}")
      nil
    end

    def record_finish(notification)
      job = notification.payload.fetch(:job)
      run = find_by(job_id: job.job_id, executions: job.executions)
      return unless run

      error = notification.payload[:exception_object]
      aborted = notification.payload[:aborted]
      run.update!(
        status: error || aborted ? "failed" : "succeeded",
        finished_at: Time.current,
        duration_ms: notification.duration.round,
        error_class: error&.class&.name || ("ActiveJob::ExecutionAborted" if aborted),
        error_message: error&.message || ("A before_perform callback halted execution" if aborted)
      )
    rescue StandardError => tracking_error
      Rails.logger.warn("ActiveJob run tracking could not finish: #{tracking_error.class}: #{tracking_error.message}")
    end
  end
end
