class StaffController < Flex::StaffController
  # This controller inherits from Flex::StaffController and provides access to the staff dashboard.
  before_action :authenticate_user!

  # TODO implement staff policy
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  # The only available endpoint by default is the 'index' action, which renders the staff dashboard.
  # You can add additional actions as needed for your specific staff workflows.
  #
  # To customize the case classes displayed in the header navigation:
  # 
  # Override the case_classes method to return an array of case model classes:

  def case_classes
    # Add your case classes here
    # Example: [MyCase, AnotherCase]
    []
  end
  #
  # To further customize the header cases links:
  # 
  # Override the set_header_cases_links method:
  #   protected
  #
  #   def set_header_cases_links
  #     super  # Call parent method for default behavior
  #     # Add custom logic here if needed
  #   end
end
