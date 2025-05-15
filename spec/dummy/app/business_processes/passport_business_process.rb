PassportBusinessProcess = Flex::BusinessProcess.define(:passport, PassportCase) do |bp|
  # Define steps
  bp.step('collect_application_info',
    Flex::UserTask.new("Collect App Info", UserTaskCreationService))

  bp.step('verify_identity',
    Flex::SystemProcess.new("Verify Identity", ->(kase) {
      IdentityVerificationService.new(kase).verify_identity
    }))

  bp.step('manual_adjudicator_review',
    Flex::UserTask.new("Manual Adjudicator Review", AdjudicatorTaskCreationService))

  bp.step('review_passport_photo',
    Flex::SystemProcess.new("Review Passport Photo", ->(kase) {
      PhotoVerificationService.new(kase).verify_photo
    }))

  bp.step('notify_user_passport_approved',
    Flex::SystemProcess.new("Notify Passport Approval", ->(kase) {
      UserNotificationService.new(kase).send_notification("approval")
    }))

  bp.step('notify_user_passport_rejected',
    Flex::SystemProcess.new("Notify Passport Rejection", ->(kase) {
      UserNotificationService.new(kase).send_notification("rejection")
    }))

  # Define start step
  bp.start("collect_application_info")

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
