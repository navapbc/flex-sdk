# frozen_string_literal: true

module Strata
  module Events
    # Routes and delivers one committed domain event.
    class DispatchJob < Strata::ApplicationJob
      discard_on StandardError

      def perform(event_id)
        Strata::Events::Processor.call(event_id, raise_on_failure: false)
      end
    end
  end
end
