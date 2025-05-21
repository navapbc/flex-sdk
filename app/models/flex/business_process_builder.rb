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

    def start(step_name, on: nil, &handler)
      @start_step_name = step_name
      @start_events ||= {}
      if on.present?
        @start_events[on] = handler
      else
        start_on_application_form_created(step_name)
      end
    end

    def start_on_application_form_created(step_name)
      event_name = @case_class.name.sub("Case", "ApplicationFormCreated")
      start(step_name, on: event_name) do |event|
        @case_class.new(application_form_id: event[:payload][:application_form_id])
      end
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
        transitions: @transitions,
        start_events: @start_events
      )
    end
  end
end
