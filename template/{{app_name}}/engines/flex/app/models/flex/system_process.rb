module Flex
  class SystemProcess
    include Step

    attr_accessor :name
    attr_accessor :callback

    def initialize(name:, callback:)
      @name = name
      @callback = callback
    end

    def execute(kase)
      @callback.call(kase)
    end
  end
end
