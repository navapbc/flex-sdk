module Flex
  class PassportApplicationBusinessProcessManager
    include Singleton

    attr_reader :business_process

    private

    def initialize
      @business_process = create_passport_application_business_process
    end

    def create_passport_application_business_process
      business_process = BusinessProcess.new(
        name: 'Passport Application Process',
        find_case_callback: ->(case_id) { PassportCase.find(case_id) },
        description: 'Process for applying for a passport'
      )
      business_process.define_steps(
        {
          "collect_application_info" => UserTask.new(
            "Collect App Info",
            UserTaskCreationService
          ),
          "verify_identity" => SystemProcess.new("Verify Identity", ->(kase) {
            IdentityVerificationService.new(kase).verify_identity # IdentityVerificationService would publish an event when verify_identity completes
          }),
          "manual_adjudicator_review" => UserTask.new("Manual Adjudicator Review", AdjudicatorTaskCreationService), # create an adjudicator task for manual review
          "review_passport_photo" => SystemProcess.new("Review Passport Photo", ->(kase) {
            PhotoVerificationService.new(kase).verify_photo # PhotoVerificationService would publish an event when verify_photo completes
          }),
          "notify_user_passport_approved" => SystemProcess.new("Notify Passport Approval", ->(kase) {
            UserNotificationService.new(kase).send_notification("approval") # UserNotificationService would publish an event when send_notification completes
          }),
          "notify_user_passport_rejected" => SystemProcess.new("Notify Passport Rejection", ->(kase) {
            UserNotificationService.new(kase).send_notification("rejection") # UserNotificationService would publish an event when send_notification completes
          })
        }
      )
      business_process.define_transitions(
        {
          "collect_application_info" => {
            "application_submitted" => 'verify_identity',
            "application_cancelled" => 'end'
          },
          "verify_identity" => {
            "identity_verified" => 'review_passport_photo',
            "identity_warning" => 'manual_adjudicator_review'
          },
          "manual_adjudicator_review" => {
            "identity_verified" => 'review_passport_photo',
            "identity_rejected" => 'application_rejected'
          },
          "review_passport_photo" => {
            "passport_photo_approved" => 'notify_user_passport_approved',
            "passport_photo_rejected" => 'review_passport_photo'
          },
          "notify_user_passport_approved" => {
            "notification_completed" => "end"
          },
          "notify_user_passport_rejected" => {
            "notification_completed" => 'end'
          }
        }
      )
      business_process.define_start('collect_application_info')

      business_process
    end
  end
end
