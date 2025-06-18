require 'rails_helper'

RSpec.describe Flex::Case do
  let(:test_case) { TestCase.create!(application_form_id: 'test-form-123') }
  let(:published_events) { [] }

  before do
    # Capture published events
    allow(Flex::EventManager).to receive(:publish) do |event_name, payload|
      published_events << { name: event_name, payload: payload }
    end
  end

  describe 'after_save callback' do
    context 'when case is created' do
      it 'publishes CaseUpdated event with correct payload' do
        new_case = TestCase.create!(
          application_form_id: 'new-form-456',
          business_process_current_step: 'initial_step'
        )

        expect(published_events).to include(
          hash_including(
            name: 'CaseUpdated',
            payload: hash_including(
              kase: new_case,
              changed_attributes: array_including('id', 'application_form_id', 'business_process_current_step')
            )
          )
        )
      end
    end

    context 'when case is updated' do
      before do
        test_case.save! # Clear any initial creation events
        published_events.clear
      end

      it 'publishes CaseUpdated event when business_process_current_step changes' do
        test_case.business_process_current_step = 'new_step'
        test_case.save!

        expect(published_events).to include(
          hash_including(
            name: 'CaseUpdated',
            payload: hash_including(
              kase: test_case,
              changed_attributes: array_including('business_process_current_step')
            )
          )
        )
      end

      it 'publishes CaseUpdated event when status changes' do
        test_case.close

        expect(published_events).to include(
          hash_including(
            name: 'CaseUpdated',
            payload: hash_including(
              kase: test_case,
              changed_attributes: array_including('status')
            )
          )
        )
      end

      it 'publishes CaseUpdated event when facts change' do
        test_case.facts = { 'priority' => 'high', 'category' => 'urgent' }
        test_case.save!

        expect(published_events).to include(
          hash_including(
            name: 'CaseUpdated',
            payload: hash_including(
              kase: test_case,
              changed_attributes: array_including('facts')
            )
          )
        )
      end

      it 'publishes CaseUpdated event when multiple attributes change' do
        test_case.business_process_current_step = 'updated_step'
        test_case.facts = { 'updated' => true }
        test_case.save!

        expect(published_events).to include(
          hash_including(
            name: 'CaseUpdated',
            payload: hash_including(
              kase: test_case,
              changed_attributes: array_including('business_process_current_step', 'facts')
            )
          )
        )
      end
    end

    context 'when case is saved without changes' do
      before do
        test_case.save! # Clear any initial creation events
        published_events.clear
      end

      it 'does not publish CaseUpdated event' do
        test_case.save!

        case_updated_events = published_events.select { |event| event[:name] == 'CaseUpdated' }
        expect(case_updated_events).to be_empty
      end

      it 'does not publish CaseUpdated event when touching without changes' do
        test_case.touch

        case_updated_events = published_events.select { |event| event[:name] == 'CaseUpdated' }
        expect(case_updated_events).to be_empty
      end
    end
  end

  describe 'inheritance behavior' do
    it 'inherits CaseUpdated event behavior in child classes' do
      # Use existing TestCase which inherits from Flex::Case
      test_case.business_process_current_step = 'inherited_test'
      test_case.save!

      expect(published_events).to include(
        hash_including(
          name: 'CaseUpdated',
          payload: hash_including(
            kase: test_case,
            changed_attributes: array_including('business_process_current_step')
          )
        )
      )
    end
  end

  describe 'event payload structure' do
    before do
      test_case.save! # Clear any initial creation events
      published_events.clear
    end

    it 'does not include case_id in payload' do
      test_case.business_process_current_step = 'test_step'
      test_case.save!

      event = published_events.find { |e| e[:name] == 'CaseUpdated' }
      expect(event[:payload]).not_to have_key(:case_id)
    end

    it 'includes kase as the actual case instance' do
      test_case.business_process_current_step = 'test_step'
      test_case.save!

      event = published_events.find { |e| e[:name] == 'CaseUpdated' }
      expect(event[:payload][:kase]).to be_a(TestCase)
      expect(event[:payload][:kase]).to eq(test_case)
    end

    it 'includes changed_attributes as array of strings' do
      test_case.business_process_current_step = 'test_step'
      test_case.facts = { 'new' => 'data' }
      test_case.save!

      event = published_events.find { |e| e[:name] == 'CaseUpdated' }
      expect(event[:payload][:changed_attributes]).to be_a(Array)
      expect(event[:payload][:changed_attributes]).to all(be_a(String))
      expect(event[:payload][:changed_attributes]).to include('business_process_current_step', 'facts')
    end
  end
end
