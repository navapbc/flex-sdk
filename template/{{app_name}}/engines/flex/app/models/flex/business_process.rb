module Flex
  class BusinessProcess
    include Step

    attr_accessor :name, :description, :steps, :start, :transitions

    def initialize(name:, type:, description: "", steps: {}, start: "", transitions: {})
      @subscriptions = {}
      @name = name
      @type = type # recognizing this is a code smell that we will want to address in the future
      @description = description
      define_start(start)
      define_steps(steps)
      define_transitions(transitions)
      start_listening_for_events
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
      if @subscriptions.any?
        stop_listening_all_events
      end

      @transitions = transitions
      start_listening_for_events
    end

    private

    def handle_event(event)
      kase = @type.find(event[:payload][:case_id])
      current_step = kase.business_process_current_step
      next_step = @transitions[current_step][event[:name]]
      kase.business_process_current_step = next_step
      kase.save!
      if next_step == "end"
        kase.close
      else
        @steps[next_step].execute(kase)
      end
    end

    def get_event_names_from_transitions
      @transitions.values.flat_map(&:keys).uniq
    end

    def start_listening_for_events
      get_event_names_from_transitions.each do |event_name|
        new_subscription = EventManager.subscribe(event_name, ->(event) {
          handle_event(event)
        })
        @subscriptions[event_name] = new_subscription
      end
    end

    def stop_listening_all_events
      @subscriptions.each do |event_name, subscription|
        EventManager.unsubscribe(subscription)
      end
      @subscriptions.clear
    end
  end
end
