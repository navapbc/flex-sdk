# frozen_string_literal: true

module Strata
  module Events
    # Recovers events that were never routed and retries due deliveries.
    class Sweeper
      Result = Struct.new(:events, :deliveries, keyword_init: true)

      def self.call(limit: Strata::Events.config.batch_size)
        processed_event_ids = sweep_events(limit)
        processed_delivery_ids = sweep_deliveries(limit)
        Result.new(events: processed_event_ids.size, deliveries: processed_delivery_ids.size)
      end

      def self.sweep_events(limit)
        process_locked(Strata::Event.ready_for_routing, limit) do |event|
          Strata::Events::Processor.call(event.id, raise_on_failure: false)
        end
      end
      private_class_method :sweep_events

      def self.sweep_deliveries(limit)
        return [] unless limit.positive?

        process_locked(Strata::EventDelivery.ready_for_retry, limit) do |delivery|
          Strata::Events::Deliverer.call(delivery)
        rescue StandardError
          # Deliverer persisted and reported the failure. Continue so one
          # poison delivery cannot prevent other due work from being retried.
        end
      end
      private_class_method :sweep_deliveries

      def self.process_locked(scope, limit)
        processed_ids = []
        scope.model.transaction do
          scope.lock("FOR UPDATE SKIP LOCKED").limit(limit).each do |record|
            yield(record)
            processed_ids << record.id
          end
        end
        processed_ids
      end
      private_class_method :process_locked
    end
  end
end
