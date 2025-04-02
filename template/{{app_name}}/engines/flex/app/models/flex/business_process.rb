module Flex
  class BusinessProcess < ApplicationRecord
    include Step
    self.abstract_class = true

    belongs_to :kase, class_name: 'Flex::Case', foreign_key: 'case_id'

    attr_accessor :name, :description, :steps, :current_step

    attribute :status, :integer, default: 0
    enum status: { pending: 0, in_progress: 1, completed: 2, failed: 3 } # Just temporary statuses

    validates :name, presence: true
    
    def execute(kase)
      raise NotImplementedError, "Subclasses must implement the `execute` method"
    end

    def defineSteps(steps)
      @steps = steps
    end
  end
end
