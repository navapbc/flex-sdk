module Flex
  class EventManager
    class << self
      def subscribe(event_key, callback)
        subscription = ActiveSupport::Notifications.subscribe(event_key) do |name, _started, _finished, _unique_id, payload|
          callback.call({
            name: name,
            payload: payload
          })
        end

        subscription
      end

      def unsubscribe(subscription)
        ActiveSupport::Notifications.unsubscribe(subscription)
      end

      def publish(event_key, payload = {})
        Rails.logger.debug "Event Manager: Publishing event '#{event_key}' with payload: #{payload.inspect}"
        ActiveSupport::Notifications.instrument(event_key, payload)
      end
    end

    private

    def initialize
      # setting initialize to private so that we cannot make new instances of it
    end
  end
end
