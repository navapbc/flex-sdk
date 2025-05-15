module Flex
  class BusinessProcess
    include Step

    attr_accessor :name, :description, :steps, :start, :transitions, :case_class

    def initialize(name:, case_class:, description: "", steps: {}, start: "", transitions: {})
      @subscriptions = {}
      @name = name
      @case_class = case_class
      @description = description
      @start = start
      @steps = steps
      @transitions = transitions
    end

    def execute(kase)
      if kase.business_process_current_step.blank?
        kase.business_process_current_step = @start
      end
      steps[start].execute(kase)
      kase.save!
    end

    def start_listening_for_events
      puts "Flex::BusinessProcess #{name} starting to listen for events"
      get_event_names_from_transitions.each do |event_name|
        puts "Flex::BusinessProcess with name #{name} subscribing to event: #{event_name}"
        @subscriptions[event_name] = EventManager.subscribe(event_name, method(:handle_event))
      end
    end

    def stop_listening_for_events
      @subscriptions.each do |event_name, subscription|
        puts "Flex::BusinessProcess with name #{name} unsubscribing from event: #{event_name}"
        EventManager.unsubscribe(subscription)
      end
      @subscriptions.clear
    end

    private

    def handle_event(event)
      kase = @case_class.find(event[:payload][:case_id])
      current_step = kase.business_process_current_step
      next_step = @transitions[current_step][event[:name]]
      kase.business_process_current_step = next_step
      if next_step == "end"
        kase.close
      else
        @steps[next_step].execute(kase)
      end
      kase.save!
    end

    def get_event_names_from_transitions
      @transitions.values.flat_map(&:keys).uniq
    end

    class << self
      def define(name, case_class)
        business_process_builder = BusinessProcessBuilder.new(name, case_class)
        yield business_process_builder
        @@business_processes[name] = business_process_builder.build
        @@business_processes[name].start_listening_for_events
      end

      def get_by_name(name)
        @@business_processes[name] || raise(ArgumentError, "No business process registered with name: #{name}")
      end
    end

    private

    @@business_processes = {}
  end
end
