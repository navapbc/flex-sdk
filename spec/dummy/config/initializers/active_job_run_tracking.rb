# frozen_string_literal: true

# Keep a dummy-app ledger by observing the lifecycle events ActiveJob already
# publishes. Subscriber failures are contained by ActiveJobRun so this
# developer instrumentation cannot alter job behavior.
ActiveSupport::Notifications.subscribe("perform_start.active_job") do |notification|
  ActiveJobRun.record_start(notification.payload.fetch(:job))
end

ActiveSupport::Notifications.subscribe("perform.active_job") do |notification|
  ActiveJobRun.record_finish(notification)
end
