PassportBusinessProcess = Flex::BusinessProcess.define(:passport, PassportCase) do |bp|
  # Define steps
  bp.staff_task('collect_application_info', StaffTaskCreationService)

  bp.system_process('verify_identity', ->(kase) {
    IdentityVerificationService.new(kase).verify_identity
  })

  bp.staff_task('manual_adjudicator_review', AdjudicatorTaskCreationService)

  bp.system_process('review_passport_photo', ->(kase) {
    PhotoVerificationService.new(kase).verify_photo
  })

  bp.system_process('notify_user_passport_approved', ->(kase) {
    UserNotificationService.new(kase).send_notification("approval")
  })

  bp.system_process('notify_user_passport_rejected', ->(kase) {
    UserNotificationService.new(kase).send_notification("rejection")
  })

  # Define start step
  bp.start_on_application_form_created('collect_application_info')

  # Define transitions
  bp.transition('collect_application_info', 'PassportApplicationFormSubmitted', 'verify_identity')
  bp.transition('collect_application_info', 'application_cancelled', 'end')
  bp.transition('verify_identity', 'identity_verified', 'review_passport_photo')
  bp.transition('verify_identity', 'identity_warning', 'manual_adjudicator_review')
  bp.transition('manual_adjudicator_review', 'identity_verified', 'review_passport_photo')
  bp.transition('manual_adjudicator_review', 'identity_rejected', 'application_rejected')
  bp.transition('review_passport_photo', 'passport_photo_approved', 'notify_user_passport_approved')
  bp.transition('review_passport_photo', 'passport_photo_rejected', 'review_passport_photo')
  bp.transition('notify_user_passport_approved', 'notification_completed', 'end')
  bp.transition('notify_user_passport_rejected', 'notification_completed', 'end')
end
