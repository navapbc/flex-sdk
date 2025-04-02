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
      raise "Business process #{name} is already started or has been completed" unless status == "pending"

      steps = get_steps
      first_step_key, first_step_value = steps.first

      self.status = "in_progress"
      self.current_step = first_step_key
      self.save!

      step.execute(self.kase)
    end

    protected

    def get_steps()
      raise NotImplementedError, "Subclasses must implement the `get_steps` method"
    end
  end
end
