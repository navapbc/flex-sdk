require 'rails_helper'

module Flex
  RSpec.describe EventsManager, type: :helper do
    let(:mock_active_support_notifications) { class_double(ActiveSupport::Notifications) }

    before do
      stub_const("ActiveSupport::Notifications", mock_active_support_notifications)
      allow(mock_active_support_notifications).to receive(:subscribe)
    end

    describe '#subscribe' do
      it 'adds "flex.events" to the beginning of a given event key' do
        given_event_key = "test_event"
        expected_event_key = "flex.events.test_event"
        callback = -> { puts "Test event triggered" }

        EventsManager.subscribe(given_event_key, callback)

        expect(mock_active_support_notifications).to have_received(:subscribe).with(expected_event_key)
      end
    end
  end
end