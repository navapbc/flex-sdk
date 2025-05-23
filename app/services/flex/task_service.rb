module Flex
  module TaskService
    mattr_accessor :implementation

    def self.configure(impl)
      self.implementation = impl
    end

    def self.create_task(*args)
      implementation.create_task(*args)
    end
  end
end
