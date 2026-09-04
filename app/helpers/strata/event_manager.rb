# frozen_string_literal: true

module Strata
  # Persists domain events for durable routing through {Strata::Events}.
  #
  # This class is used throughout the Strata SDK for handling transitions
  # between workflow steps and notifying components of state changes.
  #
  # @example Publishing an event
  #   Strata::EventManager.publish("FormSubmitted", { form_id: 123 })
  #
  class EventManager
    class << self
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
        ActiveRecord.after_all_transactions_commit do
          Strata::Events.enqueue(Strata::Events::DispatchJob, event.id)
        end
        event
      end
    end

    private

    def initialize
      # setting initialize to private so that we cannot make new instances of it
    end
  end
end
