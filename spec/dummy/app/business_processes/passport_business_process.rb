# frozen_string_literal: true

class PassportBusinessProcess < Strata::BusinessProcess
  # Define steps
  applicant_task('submit_application')

  system_process('verify_identity', ->(kase) {
    IdentityVerificationService.new(kase).verify_identity
  })

  staff_task('review_passport_photo', PassportPhotoTask)

  # Define start step
  start_on_application_form_created('submit_application')

  # Define transitions
  transition('submit_application', 'PassportApplicationFormSubmitted', 'verify_identity')
  transition('verify_identity', 'IdentityVerified', 'review_passport_photo')
  transition('review_passport_photo', 'PassportPhotoApproved', 'end')
end
