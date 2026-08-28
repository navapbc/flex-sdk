# frozen_string_literal: true

module Strata
  module Events
    module Dispatcher
      # Interface for scheduling dispatch of a persisted event.
      class Base
        def dispatch(_event)
          raise NoMethodError, "#{self.class} must implement dispatch"
        end
      end
    end
  end
end
