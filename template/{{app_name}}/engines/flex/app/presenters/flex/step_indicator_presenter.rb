module Flex
  class StepIndicatorPresenter
    def initialize(steps, current_step)
      @steps = steps.map(&:to_sym)
      @current_step = current_step.to_sym
    end

    def steps
      current_step_index = @steps.index(@current_step) || -1
      @steps.map.with_index do |step, index|
        {
          name: step,
          complete: index <= current_step_index,
          current: step == @current_step
        }
      end
    end
  end
end
