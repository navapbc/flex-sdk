module Flex
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
