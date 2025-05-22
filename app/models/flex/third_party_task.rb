module Flex
  # ThirdPartyTask represents a task that requires interaction from a third party.
  # It is used in business processes to create tasks that third parties
  # need to complete.
  #
  # @example Defining a third party task in a business process
  #   bp.step('verify_external_documents',
  #     Flex::ThirdPartyTask.new("Verify External Documents"))
  #
  # Key features:
  # - Simple logging of task execution
  # - Integration with business processes for third party workflow
  #
  class ThirdPartyTask
    include Step

    attr_reader :name

    def initialize(name)
      @name = name
    end

    def execute(kase)
      Rails.logger.info "Executing ThirdPartyTask '#{name}' for case ID: #{kase.id}"
    end
  end
end
