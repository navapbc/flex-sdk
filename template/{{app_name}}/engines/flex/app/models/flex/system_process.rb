module Flex
  class SystemProcess
    include Step
    include ActiveModel::Model
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend ActiveModel::Naming

    attr_accessor :name
    attr_accessor :callback

    validates :name, :callback, presence: true

    def initialize(callback)
      @callback = callback
    end
    
    def execute(kase)
      @callback.call(kase)
    end
  end
end
