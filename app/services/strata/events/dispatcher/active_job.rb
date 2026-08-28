# frozen_string_literal: true

module Strata
  module Events
    module Dispatcher
      # Enqueues dispatch through the host application's configured ActiveJob
      # adapter. Retry timing remains owned by delivery rows and the sweeper.
      class ActiveJob < Base
        def dispatch(event)
          ActiveRecord.after_all_transactions_commit do
            Strata::Events::DispatchJob.perform_later(event.id)
          end
          event
        end
      end
    end
  end
end
