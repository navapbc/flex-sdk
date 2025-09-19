module Flex
  # BusinessProcessBuilder is a DSL for defining business processes.
  # It provides methods for adding steps, defining transitions, and
  # setting the start step of a business process.
  #
  # This class is used by BusinessProcess.define to create new process definitions.
  #
  # @@example Creating a business process definition
  #   MyBusinessProcess = Flex::BusinessProcess.define(:my_process, MyCase) do |bp|
  #     bp.step('collect_info', Flex::StaffTask.new(...))
  #     bp.step('process_data', Flex::SystemProcess.new(...))
  #     bp.start('collect_info')
  #     bp.transition('collect_info', 'form_submitted', 'process_data')
  #   end
  #
  # Key methods:
  # - step: Adds a step to the process
  # - start: Sets the starting step
  # - transition: Defines transitions between steps based on events
  #
  module BusinessProcessBuilder
    extend ActiveSupport::Concern

    class_methods do
      attr_accessor :start_step_name

      def steps
        @steps ||= {}
      end

      def transitions
        @transitions ||= {}
      end

      def start_events
        @start_events ||= {}
      end

      # Sets the starting step for the business process and optionally configures when it should start
      #
      # @param step_name [String] The name of the step that should be the starting point of the process
      # @param on [String, nil] The event name that triggers the start of the process. If nil,
      #   defaults to starting on application form creation via start_on_application_form_created
      # @param handler [Proc] An optional block that handles the start event. The block receives
      #   the event as a parameter and should return a new case instance
      def start(step_name, on: nil, &handler)
        self.start_step_name = step_name
        if on.present?
          start_events[on] = handler
        else
          start_on_application_form_created(step_name)
        end
      end

      def start_on_application_form_created(step_name)
        event_name = "#{case_class.application_form_class.name}Created"
        start(step_name, on: event_name) do |event|
          case_class.new(application_form_id: event[:payload][:application_form_id])
        end
      end

      def step(name, step)
        steps[name] = step
      end

      def staff_task(name, task_class)
        step(name, Flex::StaffTask.new(task_class, Flex::TaskService.get))
      end

      def system_process(name, callable)
        step(name, Flex::SystemProcess.new(name, callable))
      end

      def applicant_task(name)
        step(name, Flex::ApplicantTask.new(name))
      end

      def third_party_task(name)
        step(name, Flex::ThirdPartyTask.new(name))
      end

      def transition(from, event_name, to)
        transitions[from] ||= {}
        transitions[from][event_name] = to
      end
    end
  end
end
