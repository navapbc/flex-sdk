# frozen_string_literal: true

module Strata
  module Events
    module Dispatcher
      # Dispatches in the publisher process, but only after the outermost
      # database transaction has committed.
      class Inline < Base
        def dispatch(event)
          ActiveRecord.after_all_transactions_commit do
            Strata::Events::Processor.call(event.id, raise_on_failure: true)
          end
          event
        end
      end
    end
  end
end
