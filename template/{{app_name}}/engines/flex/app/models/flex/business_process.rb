module Flex
  class BusinessProcess
    include Step

    attr_accessor :name, :description, :steps, :start, :transitions

    def initialize(name:, description: "", steps: {}, start: "", transitions: {})
      @name = name
      @description = description
      @steps = steps
      @start = start
      @transitions = transitions
    end

    def execute(kase)
      steps[start].execute(kase)
    end

    def define_start(step_name)
      @start = step_name
    end

    def define_steps(steps)
      @steps = steps
    end

    def define_transitions(transitions)
      @transitions = transitions
    end
  end
end
