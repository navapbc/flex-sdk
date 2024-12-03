require "active_support/application_subscriber"

class ApplicationSubscriber < ActiveSupport::ApplicationSubscriber
  def application_submitted(event)
    puts "Zzzzzzzzzz"
    application = event.payload[:application]
    Rails.logger.debug("Application in event: #{application.inspect}")

    process = PaidLeaveApplicationBusinessProcess.create(application_id: application.id)
    if process.persisted?
      Rails.logger.debug("Process created: #{process.inspect}")
    else
      Rails.logger.error("Process creation failed: #{process.errors.full_messages}")
    end

    return "scream"

  end
end

ApplicationSubscriber.attach_to :flex_sdk_paid_leave_application