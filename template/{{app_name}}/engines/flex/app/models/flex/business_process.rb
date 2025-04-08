require_relative "../concerns/step"
module Flex
  class BusinessProcess
    include Step
    include ActiveModel::Model
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend ActiveModel::Naming

    attr_accessor :name, :description, :steps, :start, :transitions

    validates :name, presence: true

    def execute(kase)
      steps = get_remaining_steps(kase.business_process_current_step)
      steps.each { |key, step| step.execute(kase) unless key == "end" }
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

    private

    def get_remaining_steps(current_step)
      steps_in_order = get_steps_in_transitions_order
      steps_keys = steps_in_order.keys
      steps_length = steps_in_order.length
      current_step_index = steps_keys.index(current_step)
      keys_to_get_from_hash = steps_keys.slice(current_step_index, steps_length)
      steps_in_order.slice(*keys_to_get_from_hash)
    end

    def get_steps_in_transitions_order
      steps = []
      current_step = @transitions.keys.first

      while current_step
        next_step = @transitions[current_step]
        steps << current_step
        current_step = next_step
        break if current_step.nil?
      end

      steps.map { |step_name| [ step_name, @steps[step_name] ] }.to_h
    end
  end
end
