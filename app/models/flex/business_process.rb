module Flex
  # BusinessProcess is a class that allows you to define and execute business workflows with steps and event-driven transitions.
  #
  # Business process definitions should be placed in app/business_processes/ with the naming convention
  # *_business_process.rb (e.g. passport_business_process.rb, approval_business_process.rb)
  #
  # @example Defining a basic business process in app/business_processes/my_business_process.rb
  #   MyBusinessProcess = Flex::BusinessProcess.define(:my_process, MyCase) do |bp|
  #     # Define steps - can be UserTask or SystemProcess
  #     bp.step('collect_info',
  #       Flex::UserTask.new("Collect Information", TaskCreationService))
  #
  #     bp.step('process_data',
  #       Flex::SystemProcess.new("Process Data", ->(kase) {
  #         DataProcessor.new(kase).process
  #       }))
  #
  #     # Set the starting step
  #     bp.start('collect_info')
  #
  #     # Define transitions between steps based on events
  #     bp.transition('collect_info', 'form_submitted', 'process_data')
  #     bp.transition('process_data', 'processing_complete', 'end')
  #   end
  #
  # Steps can be either:
  # - UserTask: Tasks that require human interaction
  # - SystemProcess: Automated tasks that run without user intervention
  #
  # The process automatically listens for events and transitions between steps
  # based on the defined transitions. When a step transitions to 'end',
  # the case is automatically closed.
  #
  # @see Flex::UserTask
  # @see Flex::SystemProcess
  #
  # Key Methods:
  # - start_listening_for_events: Starts listening for events that trigger transitions
  # - stop_listening_for_events: Stops listening for events (useful for cleanup)
  #
  # Class Methods:
  # @method define(name, case_class)
  #   Creates a new BusinessProcess definition
  #   @param [Symbol] name The name of the business process
  #   @param [Class] case_class The case class this process operates on
  #   @yield [BusinessProcessBuilder] builder DSL for defining the process
  #   @return [BusinessProcess] The configured business process
  #
  # Instance Methods:
  #
  # @method start_listening_for_events
  #   Starts listening for events that can trigger transitions
  #
  # @method stop_listening_for_events
  #   Stops listening for events, useful for cleanup in tests
  #
  class BusinessProcess
    include Step

    attr_accessor :name, :description, :steps, :transitions, :case_class

    def initialize(name:, case_class:, description: "", steps: {}, start_step_name: "", transitions: {})
      @subscriptions = {}
      @name = name
      @case_class = case_class
      @description = description
      @steps = steps
      @transitions = transitions
      @transitions["start"] = { start_event_name => start_step_name }
      @listening = false
    end

    def start_listening_for_events
      if @listening
        Rails.logger.debug "Flex::BusinessProcess with name #{name} already listening for events"
        return
      end

      get_event_names_from_transitions.each do |event_name|
        Rails.logger.debug "Flex::BusinessProcess with name #{name} subscribing to event: #{event_name}"
        @subscriptions[event_name] = EventManager.subscribe(event_name, method(:handle_event))
      end

      @listening = true
    end

    def stop_listening_for_events
      Rails.logger.debug "Flex::BusinessProcess with name #{name} stopping listening for events"

      @subscriptions.each do |event_name, subscription|
        Rails.logger.debug "Flex::BusinessProcess with name #{name} unsubscribing from event: #{event_name}"
        EventManager.unsubscribe(subscription)
      end
      @subscriptions.clear
      @listening = false
    end

    private

    def transition_case(kase, event_name)
      current_step = kase.business_process_current_step
      next_step = @transitions&.dig(current_step, event_name)
      Rails.logger.debug "Transitioning from #{current_step} to #{next_step} on event: #{event_name}"
      return unless next_step # Skip processing if no valid transition exists

      kase.business_process_current_step = next_step
      kase.save!
    end

    def execute_current_step(kase)
      step_name = kase.business_process_current_step
      Rails.logger.debug "Executing current step: #{step_name} for case ID: #{kase.id}"
      if step_name == "end"
        kase.close
      else
        @steps[step_name].execute(kase)
      end
    end

    def handle_event(event)
      Rails.logger.debug "Handling event: #{event[:name]} with payload: #{event[:payload]}"
      if event[:name] == start_event_name
        kase = create_case_from_event(event)
      else
        kase = get_case_from_event(event)
      end

      transition_case(kase, event[:name])
      execute_current_step(kase)
    end

    def get_event_names_from_transitions
      @transitions.values.flat_map(&:keys).uniq
    end

    def start_event_name
      @case_class.name.sub("Case", "ApplicationFormCreated")
    end

    def create_case_from_event(event)
      Rails.logger.debug "Creating case from event: #{event[:name]} with payload: #{event[:payload]}"
      raise "Cannot create case from event #{event[:name]}. Event must be an ApplicationFormCreated event" unless event[:name].end_with?("ApplicationFormCreated")
      kase = @case_class.create!(application_form_id: event[:payload][:application_form_id])
      kase
    end

    def get_case_from_event(event)
      Rails.logger.debug "Getting case from event: #{event[:name]} with payload: #{event[:payload]}"
      if event[:payload].key?(:application_form_id)
        Rails.logger.debug "Getting case from event payload with application_form_id"
        @case_class.find_by(application_form_id: event[:payload][:application_form_id])
      else
        Rails.logger.debug "Getting case from event payload with case_id"
        @case_class.find(event[:payload][:case_id])
      end
    end

    class << self
      def define(name, case_class)
        business_process_builder = BusinessProcessBuilder.new(name, case_class)
        yield business_process_builder
        business_process = business_process_builder.build
        business_process.start_listening_for_events
        business_process
      end
    end
  end
end
