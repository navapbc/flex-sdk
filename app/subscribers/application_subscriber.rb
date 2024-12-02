class ApplicationSubscriber < ActiveSupport::ApplicationSubscriber
  def application_submitted(event)
    puts "HERE2"
    application = event.payload[:application]
    process = PaidLeaveApplicationBusinessProcess.create(application_id: application.id)

  end
end

ApplicationSubscriber.attach_to :flex_sdk_paid_leave_application