# frozen_string_literal: true

module Strata
  module Auth
    module Strategies
      # Base is an abstract base class for authentication strategies.
      # It defines the interface for authentication strategies.
      #
      # Subclasses must implement the #authenticate! method.
      #
      # @example Implementing a strategy
      #   class MyStrategy < Base
      #     def authenticate!(request)
      #       # Implement authentication logic here
      #     end
      #   end
      class Base
        def authenticate!(request)
          raise NotImplementedError, "#{self.class} must implement #authenticate!"
        end

        private

        def fail_auth!(error_class, message)
          raise error_class, message
        end
      end
    end
  end
end
