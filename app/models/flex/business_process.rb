module Flex
  # BusinessProcess is a class that allows you to define and execute business workflows with steps and event-driven transitions.
  #
  # Business process definitions should be placed in app/business_processes/ with the naming convention
  # *_business_process.rb (e.g. passport_business_process.rb, approval_business_process.rb)
  #
  # @example Defining a basic business process in app/business_processes/my_business_process.rb
  #   MyBusinessProcess = Flex::BusinessProcess.define(:my_process, MyCase) do |bp|
  #     # Define steps - can be StaffTask or SystemProcess
  #     bp.step('collect_info',
  #       Flex::StaffTask.new("Collect Information", TaskCreationService))
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
  # - StaffTask: Tasks that require human interaction, created through a TaskCreationService
  # - SystemProcess: Automated tasks that run without user intervention, defined with a callable
  #
  # The process automatically listens for events and transitions between steps
  # based on the defined transitions. Events can be triggered by either user actions
  # or system processes. When a step transitions to 'end', the case is automatically closed.
  #
  # Event payloads must contain either case_id or application_form_id to identify the case.
  #
  # @see Flex::StaffTask
  # @see Flex::SystemProcess
  #
  # Key Methods:
  # - start_listening_for_events: Starts listening for events that trigger transitions
  # - stop_listening_for_events: Stops listening for events (useful for cleanup)
  #
  # Class Methods:
  # @method define(name, case_class)
  #   Creates a new BusinessProcess definition. Also automatically starts listening for events.
  #   @param [Symbol] name The name of the business process
  #   @param [Class] case_class The case class this process operates on
  #   @yield [BusinessProcessBuilder] builder DSL for defining the process steps and transitions
  #   @return [BusinessProcess] The configured and activated business process
  #
  # Instance Methods:
  # @method start_listening_for_events
  #   Starts listening for events that can trigger transitions. Called automatically by define.
  #
  # @method stop_listening_for_events
  #   Stops listening for events and cleans up subscriptions. Useful for cleanup in tests.
  #
  class BusinessProcess < ApplicationRecord
    include BusinessProcessBuilder

    attribute :case_id, :string
    attribute :case_type, :string
    attribute :current_step, :string

    def start_from_event(event)
      Rails.logger.debug "Starting business process from event: #{event[:name]} with payload: #{event[:payload]}"
      self.current_step = self.class.start_step_name
      save!
      execute_current_step
    end

    def transition_to_next_step(event)
      next_step = get_next_step(event[:name])
      return unless next_step

      Rails.logger.debug "Transitioning to step #{next_step} and executing the step"
      self.current_step = next_step
      save!
      execute_current_step
    end

    def self.case_class
      self.name.sub("BusinessProcess", "Case").constantize
    end

    @@listening = false
    @@subscriptions = {}
    def self.start_listening_for_events
      if @@listening
        Rails.logger.debug "Flex::BusinessProcess with name #{name} already listening for events"
        return
      end

      get_event_names.each do |event_name|
        Rails.logger.debug "Flex::BusinessProcess with name #{name} subscribing to event: #{event_name}"
        @@subscriptions[event_name] = EventManager.subscribe(event_name, method(:handle_event))
      end

      @@listening = true
    end

    def self.stop_listening_for_events
      Rails.logger.debug "Flex::BusinessProcess with name #{name} stopping listening for events"

      @@subscriptions.each do |event_name, subscription|
        Rails.logger.debug "Flex::BusinessProcess with name #{name} unsubscribing from event: #{event_name}"
        Flex::EventManager.unsubscribe(subscription)
      end
      @@subscriptions.clear
      @@listening = false
    end

    def self.to_mermaid
      diagram = "flowchart TD\n"

      steps.each do |name, step|
        node_name = name.gsub(" ", "_")
        node_class = step.class.name.demodulize
        diagram += "  #{node_name}:::#{node_class}\n"
      end

      diagram += "  END((End))\n"

      transitions.each do |from, events|
        events.each do |event, to|
          # Capitalize the "END" node since Mermaid breaks if one of the nodes is named "end" https://github.com/mermaid-js/mermaid/issues/1444
          to = "END" if to == "end"
          diagram += "  #{from} -->|#{event}| #{to}\n"
        end
      end

      diagram += [
        "classDef ApplicantTask fill:#90EE90,stroke:#333,stroke-width:2px;",
        "classDef StaffTask fill:#ffb366,stroke:#333,stroke-width:2px;",
        "classDef SystemProcess fill:#a0d8ef,stroke:#333,stroke-width:2px;",
        "classDef ThirdPartyTask fill:#c0c0ff,stroke:#333,stroke-width:2px;"
      ].join("\n")

      diagram
    end

    private

    # TODO question: what about event[:payload][:application_form_id])?
    scope :for_application_form, ->(application_form_id) do
      joins("INNER JOIN #{case_class.table_name} cases ON cases.id = #{table_name}.case_id").where(cases: { application_form_id: })
    end
    scope :for_case, ->(case_id) { where(case_id:) }
    scope :for_event, ->(event) do
      if event[:payload].key?(:application_form_id)
        Rails.logger.debug "Finding business processes for event with application_form_id: #{event[:payload][:application_form_id]}"
        for_application_form(event[:payload][:application_form_id])
      else
        Rails.logger.debug "Finding business processes for event with case_id: #{event[:payload][:case_id]}"
        for_case(event[:payload][:case_id])
      end
    end

    def execute_current_step
      kase = self.class.case_class.find(case_id)
      Rails.logger.debug "Executing current step: #{current_step} for case ID: #{kase.id}"
      if current_step == "end"
        kase.close
        destroy!
      else
        self.class.steps[current_step].execute(kase)
      end
    end

    def get_next_step(event_name)
      self.class.transitions&.dig(current_step, event_name)
    end

    class << self
      def create_case_from_event(event)
        Rails.logger.debug "Creating case from event: #{event[:name]} with payload: #{event[:payload]}"
        handler = start_events[event[:name]]
        raise RuntimeError, "No handler defined for start event '#{event[:name]}'" unless handler

        kase = handler.call(event)
        kase.save!
        kase
      end

      def get_case_from_event(event)
        Rails.logger.debug "Getting case from event: #{event[:name]} with payload: #{event[:payload]}"
        if event[:payload].key?(:application_form_id)
          Rails.logger.debug "Getting case from event payload with application_form_id"
          @@case_class.find_by(application_form_id: event[:payload][:application_form_id])
        else
          Rails.logger.debug "Getting case from event payload with case_id"
          @@case_class.find(event[:payload][:case_id])
        end
      end

      def get_event_names
        @@transitions.values.flat_map(&:keys).uniq | start_events.keys
      end

      def handle_event(event)
        Rails.logger.debug "Handling event: #{event[:name]} with payload: #{event[:payload]}"

        if start_event?(event[:name])
          business_process_instance = from_event(event)
          business_process_instance.start_from_event(event)
        else
          business_process_instances = for_event(event)
          business_process_instances.each do |business_process_instance|
            business_process_instance.transition_to_next_step(event)
          end
        end
      end

      def from_event(event)
        # TODO Put in transaction
          kase = create_case_from_event(event)
          new(case_id: kase.id, case_type: kase.class.name)
        # End transaction
      end

      def start_event?(event_name)
        @@start_events.key?(event_name)
      end
    end
  end
end
