module Flex
  # BusinessProcessBuilder is a DSL for defining business processes.
  # It provides methods for adding steps, defining transitions, and
  # setting the start step of a business process.
  #
  # This class is used by BusinessProcess.define to create new process definitions.
  #
  # @example Creating a business process definition
  #   MyBusinessProcess = Flex::BusinessProcess.define(:my_process, MyCase) do |bp|
  #     bp.step('collect_info', Flex::StaffTask.new(...))
  #     bp.step('process_data', Flex::SystemProcess.new(...))
  #     bp.start('collect_info')
  #     bp.transition('collect_info', 'form_submitted', 'process_data')
  #   end
  #
  # Key methods:
  # - step: Adds a step to the process
  # - start: Sets the starting step
  # - transition: Defines transitions between steps based on events
  #
  class BusinessProcessBuilder
    attr_reader :name, :steps, :start, :transitions, :case_class

    def initialize(name, case_class)
      @name = name
      @case_class = case_class
      @start = nil
      @steps = {}
      @transitions = {}
    end

    def start(step_name)
      @start_step_name = step_name
    end

    def step(name, step)
      steps[name] = step
    end

    def transition(from, event_name, to)
      transitions[from] ||= {}
      transitions[from][event_name] = to
    end

    def build
      BusinessProcess.new(
        name: @name,
        case_class: @case_class,
        description: "",
        steps: @steps,
        start_step_name: @start_step_name,
        transitions: @transitions
      )
    end
  end
end
