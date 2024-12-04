module FlexSdk
  class ApplicationSubscriber < ActiveSupport::Subscriber
    def application_submitted(event)
      application = event.payload[:application]
      puts application.id
      puts "herererererere"
      process = PaidLeaveApplicationBusinessProcess.create(application_id: application.id)
      puts process

      return application.id
    end
  end
end

FlexSdk::ApplicationSubscriber.attach_to :flex_sdk_paid_leave_application