module Flex
  class BusinessProcessInstance
    attr_reader :case

    def initialize(kase, current_step)
      @case = kase
    end

    def current_step
      self.case.business_process_current_step
    end

    def current_step=(step)
      self.case.business_process_current_step = step
    end

    def business_process
      self.case.class.name.sub("Case", "BusinessProcess").constantize
    end

    def start_from_event(event)
      Rails.logger.debug "Starting business process from event: #{event[:name]} with payload: #{event[:payload]}"
      self.current_step = business_process.start_step_name
      self.case.save!
      execute_current_step
    end

    def transition_to_next_step(event)
      next_step = get_next_step(event[:name])
      return unless next_step

      Rails.logger.debug "Transitioning to step #{next_step} and executing the step"
      self.current_step = next_step
      self.case.save!
      execute_current_step
    end

    private

    def execute_current_step
      Rails.logger.debug "Executing current step: #{current_step} for case ID: #{self.case.id}"
      if current_step == "end"
        self.case.close
      else
        business_process.steps[current_step].execute(self.case)
      end
    end

    def get_next_step(event_name)
      business_process.transitions&.dig(current_step, event_name)
    end
  end
end
