module Flex
  class BusinessProcessBuilder
    attr_reader :name, :steps, :start, :transitions, :find_case_callback

    def initialize(name, find_case_callback:)
      @name = name
      @start = nil
      @steps = {}
      @transitions = {}
      @find_case_callback = find_case_callback
    end

    def start(step_name)
      @start = step_name
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
        find_case_callback: @find_case_callback,
        description: "",
        steps: @steps,
        start: @start,
        transitions: @transitions
      )
    end
  end
end
