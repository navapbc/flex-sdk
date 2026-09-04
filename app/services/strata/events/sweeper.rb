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
        process_each(Strata::Event.ready_for_routing, limit) do |event|
          Strata::Events::Processor.call(event.id, raise_on_failure: false)
        end
      end
      private_class_method :sweep_events

      def self.sweep_deliveries(limit)
        process_each(Strata::EventDelivery.ready_for_retry, limit) do |delivery|
          Strata::Events::Deliverer.call(delivery)
        end
      end
      private_class_method :sweep_deliveries

      # Process each record in a separate transaction so a poison record rolls
      # back only its own work and cannot disable the rest of the sweep.
      def self.process_each(scope, limit)
        return [] unless limit.positive?

        processed_ids = []
        limit.times do
          found = false
          scope.model.transaction do
            relation = processed_ids.empty? ? scope : scope.where.not(id: processed_ids)
            record = relation.lock("FOR UPDATE SKIP LOCKED").first
            next unless record

            found = true
            processed_ids << record.id
            begin
              yield(record)
            rescue StandardError
              # Processor and Deliverer report their own failures. Rescue here
              # so failure bookkeeping commits before the sweep continues.
            end
          end
          break unless found
        end

        processed_ids
      end
      private_class_method :process_each
    end
  end
end
