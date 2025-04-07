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
      kase.business_process_current_step = start
      kase.save!
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
