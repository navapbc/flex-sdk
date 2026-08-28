# frozen_string_literal: true

module Strata
  # Persists domain events and emits matching ActiveSupport notifications for
  # instrumentation. Durable domain handlers must be registered through
  # {Strata::Events}; notification subscribers are intentionally synchronous.
  #
  # This class is used throughout the Strata SDK for handling transitions
  # between workflow steps and notifying components of state changes.
  #
  # @example Publishing an event
  #   Strata::EventManager.publish("FormSubmitted", { form_id: 123 })
  #
  # @example Subscribing to an event
  #   subscription = Strata::EventManager.subscribe("FormSubmitted") do |event|
  #     # Handle the event
  #     puts "Form #{event[:payload][:form_id]} was submitted"
  #   end
  #
  class EventManager
    @@subscriptions = []

    class << self
      # Subscribes to an event, registering a callback to be executed when the event occurs.
      #
      # @param [String] event_key The name of the event to subscribe to
      # @param [Proc, Method] callback The callback to execute when the event occurs
      # @return [Object] The subscription object, which can be used to unsubscribe
      def subscribe(event_key, callback = nil, &block)
        callback ||= block
        raise ArgumentError, "Event subscription requires a callback" unless callback

        subscription = ActiveSupport::Notifications.subscribe(event_key) do |name, _started, _finished, _unique_id, payload|
          callback.call({
            name: name,
            payload: payload
          })
        end

        @@subscriptions << subscription
        subscription
      end

      # Unsubscribes from an event by providing the subscription object.
      #
      # @param [Object] subscription The subscription object returned by subscribe
      def unsubscribe(subscription)
        ActiveSupport::Notifications.unsubscribe(subscription)
        @@subscriptions.delete(subscription)
      end

      # Unsubscribes from all instrumentation events registered through this
      # wrapper. Domain handlers are registered separately through Events.
      #
      # @return [void]
      def unsubscribe_all
        @@subscriptions.each do |subscription|
          ActiveSupport::Notifications.unsubscribe(subscription)
        end
        @@subscriptions.clear
      end

      # Publishes an event with the given key and payload.
      #
      # @param [String] event_key The name of the event to publish
      # @param [Hash] payload The event payload data
      # @return [Strata::Event] the persisted domain event
      def publish(event_key, payload = {})
        current_event = Strata::Events.current_event
        event = Strata::Event.create!(
          name: event_key,
          payload: payload,
          occurred_at: Time.current,
          correlation_id: current_event&.correlation_id || current_event&.id || SecureRandom.uuid,
          causation_id: current_event&.id
        )

        Rails.logger.info(
          "Event Manager: Published event '#{event_key}' " \
          "(id=#{event.id}, correlation_id=#{event.correlation_id})"
        )
        Strata::Events.dispatcher.dispatch(event)
        ActiveSupport::Notifications.instrument(event_key, payload)
        event
      end
    end

    private

    def initialize
      # setting initialize to private so that we cannot make new instances of it
    end
  end
end
