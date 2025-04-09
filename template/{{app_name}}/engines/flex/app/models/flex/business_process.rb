module Flex
  class BusinessProcess
    include ActiveModel::Model
    include ActiveModel::Validations
    include Step

    attr_accessor :name, :description, :steps, :start, :transitions

    validates :name, presence: true

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
      @transitions = transitions
    end
  end
end
