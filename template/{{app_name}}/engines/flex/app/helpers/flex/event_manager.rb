module Flex
  class EventManager
    def self.subscribe(event_key, callback)
      subscription = ActiveSupport::Notifications.subscribe(event_key) do |name, _started, _finished, _unique_id, payload|
        callback.call({
          name: name,
          payload: payload
        })
      end

      subscription
    end

    def self.unsubscribe(subscription)
      ActiveSupport::Notifications.unsubscribe(subscription)
    end

    def self.publish(event_key, payload = {})
      ActiveSupport::Notifications.instrument(event_key, payload)
    end

    private

    def initialize
      # setting initialize to private so that we cannot make new instances of it
    end
  end
end
