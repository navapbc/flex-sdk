# frozen_string_literal: true

class PassportBusinessProcess < Strata::BusinessProcess
  # Define steps
  applicant_task('submit_application')

  system_process('verify_identity', ->(kase) {
    IdentityVerificationService.new(kase).verify_identity
  })

  staff_task('manual_adjudicator_review', PassportTask)

  system_process('review_passport_photo', ->(kase) {
    PhotoVerificationService.new(kase).verify_photo
  })

  system_process('notify_user_passport_approved', ->(kase) {
    UserNotificationService.new(kase).send_notification("approval")
  })

  system_process('notify_user_passport_rejected', ->(kase) {
    UserNotificationService.new(kase).send_notification("rejection")
  })

  # Define start step
  start_on_application_form_created('submit_application')

  # Define transitions
  transition('submit_application', 'PassportApplicationFormSubmitted', 'verify_identity')
  transition('submit_application', 'application_cancelled', 'end')
  transition('verify_identity', 'identity_verified', 'review_passport_photo')
  transition('verify_identity', 'identity_warning', 'manual_adjudicator_review')
  transition('manual_adjudicator_review', 'identity_verified', 'review_passport_photo')
  transition('manual_adjudicator_review', 'identity_rejected', 'application_rejected')
  transition('review_passport_photo', 'passport_photo_approved', 'notify_user_passport_approved')
  transition('review_passport_photo', 'passport_photo_rejected', 'review_passport_photo')
  transition('notify_user_passport_approved', 'notification_completed', 'end')
  transition('notify_user_passport_rejected', 'notification_completed', 'end')
end
