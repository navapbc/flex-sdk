# frozen_string_literal: true

class ActiveJobRunsController < ApplicationController
  DISPLAY_LIMIT = 100

  def index
    @runs = ActiveJobRun.recent_first.limit(DISPLAY_LIMIT)
    @status_counts = ActiveJobRun.group(:status).count
    @total_count = ActiveJobRun.count
    @dispatcher_name = Strata::Events.dispatcher.class.name
    @queue_adapter_name = ActiveJob::Base.queue_adapter.class.name
      .delete_prefix("ActiveJob::QueueAdapters::")
  end
end
