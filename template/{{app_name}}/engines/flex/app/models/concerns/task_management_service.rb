module Flex
  module TaskManagementService
    extend ActiveSupport::Concern

    # user_task_type examples "VerifyIdentityTask", "UserTask"
    def create_task(user_task_type, user_task_description)
      raise NoMethodError, "#{self.class} must implement execute method"
    end
  end
end