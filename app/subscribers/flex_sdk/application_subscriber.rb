module FlexSdk
  class ApplicationSubscriber < ActiveSupport::Subscriber
    def application_submitted(event)
      application = event.payload[:application]
      process = PaidLeaveApplicationBusinessProcess.create(application_id: application.id)
      process.run
      
      return application.id
    end
  end
end

FlexSdk::ApplicationSubscriber.attach_to :flex_sdk_paid_leave_application