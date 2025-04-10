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
      @event_listeners = {}
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

    def add_event_listener(event_key, callback)
      raise "Event listener for #{event_key} already exists" if @event_listeners.key?(event_key)

      @event_listeners[event_key] = callback
    end
  end
end
