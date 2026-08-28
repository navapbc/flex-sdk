# frozen_string_literal: true

module Strata
  module Events
    # Recovers events that were never routed and retries due deliveries.
    class Sweeper
      Result = Struct.new(:events, :deliveries, keyword_init: true)

      def self.call(limit: Strata::Events.config.batch_size)
        processed_event_ids = sweep_events(limit)
        remaining = [ limit - processed_event_ids.size, 0 ].max
        processed_delivery_ids = sweep_deliveries(remaining, excluding: processed_event_ids)
        Result.new(events: processed_event_ids.size, deliveries: processed_delivery_ids.size)
      end

      def self.sweep_events(limit)
        process_locked(Strata::Event.undispatched, limit) do |event|
          Strata::Events::Processor.call(event.id, raise_on_failure: false)
        end
      end
      private_class_method :sweep_events

      def self.sweep_deliveries(limit, excluding:)
        return [] unless limit.positive?

        scope = Strata::EventDelivery.ready_for_retry
        scope = scope.where.not(strata_event_id: excluding) if excluding.any?
        processed_event_ids = []

        process_locked(scope, limit) do |delivery|
          next if processed_event_ids.include?(delivery.strata_event_id)

          Strata::Events::Processor.call(delivery.strata_event_id, raise_on_failure: false)
          processed_event_ids << delivery.strata_event_id
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
