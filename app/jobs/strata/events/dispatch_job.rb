# frozen_string_literal: true

module Strata
  module Events
    # ActiveJob entry point for durable domain-event dispatch.
    class DispatchJob < Strata::ApplicationJob
      def perform(event_id)
        Strata::Events::Processor.call(event_id, raise_on_failure: false)
      end
    end
  end
end
