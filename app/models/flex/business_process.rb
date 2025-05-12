module Flex
  class BusinessProcess
    include Step

    attr_accessor :name, :description, :steps, :start, :transitions, :find_case_callback

    def initialize(name:, find_case_callback:, description: "", steps: {}, start: "", transitions: {})
      @subscriptions = {}
      @name = name
      @find_case_callback = find_case_callback
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
      stop_listening_for_events
      @transitions = transitions
      start_listening_for_events
    end

    # @description This method will clear subscriptions and set steps, transitions, and start to their default values.
    #     Only use this method if you are finished with the instance or plan to manually reset these values.
    def clear_process_configuration
      stop_listening_for_events
      @steps = {}
      @transitions = {}
      @start = ""
    end

    private

    def handle_event(event)
      kase = @find_case_callback.call(event[:payload][:case_id])
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
        Rails.logger.debug "Flex::BusinessProcess with name #{name} subscribing to event: #{event_name}"
        @subscriptions[event_name] = EventManager.subscribe(event_name, method(:handle_event))
      end
    end

    def stop_listening_for_events
      @subscriptions.each do |event_name, subscription|
        Rails.logger.debug "Flex::BusinessProcess with name #{name} unsubscribing from event: #{event_name}"
        EventManager.unsubscribe(subscription)
      end
      @subscriptions.clear
    end
  end
end
