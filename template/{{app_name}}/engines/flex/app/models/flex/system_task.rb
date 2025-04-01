module Flex
  class SystemTask
    include Step
    include ActiveModel::Model
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend ActiveModel::Naming

    attr_accessor :name

    validates :name, presence: true

    def initialize(callback)
      @callback = callback
    end
    
    def execute(kase)
      @callback(kase)
    end

    def persisted?
      false
    end
  end
end
