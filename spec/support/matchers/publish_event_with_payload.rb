# frozen_string_literal: true

RSpec::Matchers.define :publish_event_with_payload do |event_name, expected_payload|
  supports_block_expectations

  match do |block|
    existing_ids = Strata::Event.where(name: event_name).pluck(:id)

    block.call

    @actual_payloads = Strata::Event
      .where(name: event_name)
      .where.not(id: existing_ids)
      .order(:occurred_at, :id)
      .map { |event| event.payload.deep_symbolize_keys }
    @event_triggered = @actual_payloads.any?

    payload_matcher = if RSpec::Matchers.is_a_matcher?(expected_payload)
      expected_payload
    else
      RSpec::Matchers::BuiltIn::Include.new(expected_payload)
    end
    @actual_payload = @actual_payloads.find { |payload| payload_matcher.matches?(payload) }

    @actual_payload.present?
  end

  failure_message do
    if !@event_triggered
      "expected event '#{event_name}' to be published, but it was not triggered"
    else
      "expected event payload to include #{expected_payload.inspect}, but got #{@actual_payloads.inspect}"
    end
  end

  failure_message_when_negated do
    "expected event '#{event_name}' not to be published with payload #{expected_payload.inspect}, but it was"
  end
end
