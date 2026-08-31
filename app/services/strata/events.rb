# frozen_string_literal: true

module Strata
  # Configuration, handler registry, and dispatcher locator for domain events.
  module Events
    # Host-controlled delivery, retry, and retention settings.
    class Configuration
      attr_accessor :retention_days,
        :max_attempts,
        :retry_base_delay,
        :routing_retry_delay,
        :batch_size,
        :prune_time_budget

      def initialize
        @retention_days = nil
        @max_attempts = 5
        @retry_base_delay = 1.minute
        @routing_retry_delay = 5.minutes
        @batch_size = 100
        @prune_time_budget = 30.seconds
      end
    end

    class << self
      def configure
        yield(config)
      end

      def config
        state.configuration ||= Configuration.new
      end

      def register(handler)
        handler_name = handler.is_a?(String) ? handler : handler.name
        raise ArgumentError, "Event handler must have a class name" if handler_name.blank?

        handler_names << handler_name unless handler_names.include?(handler_name)
        handler_name
      end

      def unregister(handler)
        handler_names.delete(handler.is_a?(String) ? handler : handler.name)
      end

      def handler_names
        @handler_names ||= []
      end

      def dispatcher
        state.dispatcher ||= Strata::Events::Dispatcher::Inline.new
      end

      def dispatcher=(dispatcher)
        unless valid_dispatcher?(dispatcher)
          raise ArgumentError, "Dispatcher must be a subclass of Strata::Events::Dispatcher::Base"
        end

        state.dispatcher = dispatcher
      end

      def current_event
        ActiveSupport::IsolatedExecutionState[:strata_current_event]
      end

      def current_delivery
        ActiveSupport::IsolatedExecutionState[:strata_current_delivery]
      end

      def with_current_event(event, delivery: nil)
        previous_event = current_event
        previous_delivery = current_delivery
        ActiveSupport::IsolatedExecutionState[:strata_current_event] = event
        ActiveSupport::IsolatedExecutionState[:strata_current_delivery] = delivery
        yield
      ensure
        ActiveSupport::IsolatedExecutionState[:strata_current_event] = previous_event
        ActiveSupport::IsolatedExecutionState[:strata_current_delivery] = previous_delivery
      end

      # Primarily useful for test isolation and development-console reconfiguration.
      def reset!
        state.configuration = Configuration.new
        state.dispatcher = nil
        @handler_names = []
        ActiveSupport::IsolatedExecutionState.delete(:strata_current_event)
        ActiveSupport::IsolatedExecutionState.delete(:strata_current_delivery)
      end

      private

      # Engine configuration is not reloadable, so host settings survive when
      # Zeitwerk replaces the Strata::Events module in development.
      def state
        Strata::Engine.events_state
      end

      # Rails may replace the Base constant during a development reload before
      # host configuration assigns a fresh adapter. Matching the named ancestor
      # keeps an already-configured adapter valid across that narrow window.
      def valid_dispatcher?(dispatcher)
        dispatcher.is_a?(Strata::Events::Dispatcher::Base) ||
          dispatcher.class.ancestors.any? { |ancestor| ancestor.name == "Strata::Events::Dispatcher::Base" }
      end
    end
  end
end
