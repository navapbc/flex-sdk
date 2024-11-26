module FlexSdk
  class PaidLeaveApplication < ApplicationForm
    #Program-specific fields
    validates :leave_type, presence: true

    # Example leave types -- will vary by state need to be configurable
    LEAVE_TYPES = %w[bonding care_for_self care_for_others military_exingeny safety].freeze

    # Ensure leave_type is always valid
    validates :leave_type, inclusion: { in: LEAVE_TYPES }
  end
end
