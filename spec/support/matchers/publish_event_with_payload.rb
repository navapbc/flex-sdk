RSpec::Matchers.define :publish_event_with_payload do |event_name, expected_payload|
  supports_block_expectations

  match do |block|
    @event_triggered = false
    @actual_payload = nil

    callback = ->(event) do
      @event_triggered = true
      @actual_payload = event[:payload]
    end

    subscription = Strata::EventManager.subscribe(event_name, callback)

    begin
      block.call
    ensure
      Strata::EventManager.unsubscribe(subscription) if subscription
    end

    @event_triggered && RSpec::Matchers::BuiltIn::Include.new(expected_payload).matches?(@actual_payload)
  end

  failure_message do
    if !@event_triggered
      "expected event '#{event_name}' to be published, but it was not triggered"
    else
      "expected event payload to include #{expected_payload.inspect}, but got #{@actual_payload.inspect}"
    end
  end

  failure_message_when_negated do
    "expected event '#{event_name}' not to be published with payload #{expected_payload.inspect}, but it was"
  end
end
