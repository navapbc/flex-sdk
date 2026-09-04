# frozen_string_literal: true

module Strata
  module Events
    # Creates idempotent delivery rows and attempts all work for an event.
    class Processor
      def self.call(event_id, raise_on_failure: false)
        event = Strata::Event.find_by(id: event_id)
        return unless event

        begin
          deliveries = create_deliveries(event)
        rescue StandardError => error
          report(error, event)
          return event
        end

        failures = []

        deliveries.each do |delivery|
          Strata::Events::Deliverer.call(delivery)
        rescue StandardError => error
          failures << error
        end

        raise failures.first if raise_on_failure && failures.any?

        event
      end

      def self.create_deliveries(event)
        deliveries = []

        Strata::Event.transaction(requires_new: true) do
          event.lock!
          next if event.dispatched_at? || event.next_attempt_at&.future?

          routes = Strata::Events::Router.routes_for(event)
          if routes.empty?
            event.update!(next_attempt_at: Time.current + Strata::Events.config.routing_retry_delay)
            Rails.logger.warn(
              "No registered durable handler recognizes event '#{event.name}' (id=#{event.id}); " \
              "deferring another routing attempt until #{event.next_attempt_at.iso8601}"
            )
            next
          end

          routes.each do |route|
            deliveries << find_or_create_delivery(event, route)
          end
          event.update!(dispatched_at: Time.current, next_attempt_at: nil)
        end

        deliveries
      end
      private_class_method :create_deliveries

      def self.find_or_create_delivery(event, route)
        attributes = {
          strata_event_id: event.id,
          handler: route.handler,
          target_type: route.target_type,
          target_id: route.target_id
        }
        Strata::EventDelivery.find_by(attributes) || create_delivery(attributes)
      rescue ActiveRecord::RecordNotUnique
        Strata::EventDelivery.find_by!(attributes)
      end
      private_class_method :find_or_create_delivery

      def self.create_delivery(attributes)
        Strata::EventDelivery.transaction(requires_new: true) do
          Strata::EventDelivery.create!(attributes)
        end
      end
      private_class_method :create_delivery

      def self.report(error, event)
        Rails.error.report(
          error,
          handled: true,
          context: { strata_event_id: event.id, event_name: event.name }
        )
      rescue StandardError => reporting_error
        Rails.logger.error("Unable to report event routing failure: #{reporting_error.message}")
      end
      private_class_method :report
    end
  end
end
