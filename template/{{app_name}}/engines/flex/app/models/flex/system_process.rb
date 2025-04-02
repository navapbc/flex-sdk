module Flex
  class SystemProcess
    include Step
    include ActiveModel::Model
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend ActiveModel::Naming
    self.abstract_class = true

    attr_accessor :name

    validates :name, presence: true
    
    def execute(kase)
      raise NoMethodError, "Children must implement the `execute` method"
    end

    def persisted?
      false
    end
  end
end
