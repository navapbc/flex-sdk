module Flex
  # SystemProcess represents an automated task that doesn't require human interaction.
  # It is used in business processes to perform tasks automatically through a provided callback.
  #
  # When executed, SystemProcess calls its callback with the case as an argument.
  #
  # @example Defining a system process in a business process
  #   bp.step('process_data',
  #     Flex::SystemProcess.new("Process Data", ->(kase) {
  #       DataProcessor.new(kase).process
  #     }))
  #
  # Key features:
  # - Executes automated tasks through callbacks
  # - Integrates with business processes for workflow automation
  #
  class SystemProcess
    include Step

    attr_accessor :name
    attr_accessor :callback

    def initialize(name, callback)
      @name = name
      @callback = callback
    end

    def execute(kase)
      Rails.logger.debug "Executing system process #{name}"
      @callback.call(kase)
    end
  end
end
