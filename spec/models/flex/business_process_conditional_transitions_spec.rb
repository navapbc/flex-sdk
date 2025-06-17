require 'rails_helper'

RSpec.describe Flex::BusinessProcess do
  let(:application_form) { TestApplicationForm.create!() }
  let(:kase) { TestCase.find_by(application_form_id: application_form.id) }
  let(:business_process) do
    described_class.define(:conditional_test, TestCase) do |bp|
      bp.staff_task('start_step', PassportPhotoTask)
      bp.staff_task('approved_step', PassportVerifyInfoTask)
      bp.staff_task('rejected_step', PassportPhotoTask)
      bp.system_process('end_step', ->(kase) { kase.close })

      bp.start_on_application_form_created('start_step')

      # Conditional transition based on approval status
      bp.transition('start_step', 'review_completed', 'approved_step',
        condition: [ :approval_check, ->(event) { event.payload[:approved] == true } ])

      # Conditional transition based on case facts
      bp.transition('start_step', 'review_completed', 'rejected_step',
        condition: [ :case_facts_check, ->(event) { event.kase.facts['priority'] == 'high' } ])

      # Regular transition without condition for comparison
      bp.transition('approved_step', 'finalize', 'end_step')
      bp.transition('rejected_step', 'finalize', 'end_step')
    end
  end

  before do
    business_process.start_listening_for_events
    kase.business_process_current_step = 'start_step'
    kase.save!
  end

  after do
    business_process.stop_listening_for_events
  end

  describe 'conditional transitions' do
    context 'when condition evaluates to true' do
      it 'transitions to the specified step' do
        Flex::EventManager.publish('review_completed', {
          case_id: kase.id,
          approved: true
        })

        kase.reload
        expect(kase.business_process_current_step).to eq('approved_step')
      end
    end

    context 'when condition evaluates to false' do
      it 'does not transition and maintains current step' do
        Flex::EventManager.publish('review_completed', {
          case_id: kase.id,
          approved: false
        })

        kase.reload
        expect(kase.business_process_current_step).to eq('start_step')
      end
    end

    context 'when condition accesses case facts' do
      it 'transitions when case facts match condition' do
        kase.facts = { 'priority' => 'high' }
        kase.save!

        Flex::EventManager.publish('review_completed', {
          case_id: kase.id,
          kase: kase
        })

        kase.reload
        expect(kase.business_process_current_step).to eq('rejected_step')
      end

      it 'does not transition when case facts do not match condition' do
        kase.facts = { 'priority' => 'low' }
        kase.save!

        Flex::EventManager.publish('review_completed', {
          case_id: kase.id,
          kase: kase
        })

        kase.reload
        expect(kase.business_process_current_step).to eq('start_step')
      end
    end

    context 'when condition raises an exception' do
      let(:failing_business_process) do
        described_class.define(:failing_conditional_test, TestCase) do |bp|
          bp.staff_task('start_step', PassportPhotoTask)
          bp.staff_task('next_step', PassportVerifyInfoTask)

          bp.start_on_application_form_created('start_step')

          bp.transition('start_step', 'test_event', 'next_step',
            condition: [ :failing_condition, ->(event) { raise StandardError, 'Test error' } ])
        end
      end

      before do
        failing_business_process.start_listening_for_events
        kase.business_process_current_step = 'start_step'
        kase.save!
      end

      after do
        failing_business_process.stop_listening_for_events
      end

      it 'logs a warning and does not transition' do
        allow(Rails.logger).to receive(:warn)

        Flex::EventManager.publish('test_event', { case_id: kase.id })

        expect(Rails.logger).to have_received(:warn).with(/Transition condition 'failing_condition' failed: Test error/)
        kase.reload
        expect(kase.business_process_current_step).to eq('start_step')
      end
    end

    context 'with backward compatibility' do
      let(:legacy_business_process) do
        described_class.define(:legacy_test, TestCase) do |bp|
          bp.staff_task('start_step', PassportPhotoTask)
          bp.staff_task('next_step', PassportVerifyInfoTask)

          bp.start_on_application_form_created('start_step')

          # Legacy string-based transition
          bp.transition('start_step', 'legacy_event', 'next_step')
        end
      end

      before do
        legacy_business_process.start_listening_for_events
        kase.business_process_current_step = 'start_step'
        kase.save!
      end

      after do
        legacy_business_process.stop_listening_for_events
      end

      it 'continues to work with string-based transitions' do
        Flex::EventManager.publish('legacy_event', { case_id: kase.id })

        kase.reload
        expect(kase.business_process_current_step).to eq('next_step')
      end
    end
  end

  describe 'multiple conditional transitions for same event' do
    let(:multi_condition_business_process) do
      described_class.define(:multi_condition_test, TestCase) do |bp|
        bp.staff_task('start_step', PassportPhotoTask)
        bp.staff_task('path_a', PassportVerifyInfoTask)
        bp.staff_task('path_b', PassportPhotoTask)
        bp.staff_task('default_path', PassportVerifyInfoTask)

        bp.start_on_application_form_created('start_step')

        # Multiple conditions for the same event - first matching condition wins
        bp.transition('start_step', 'route_event', 'path_a',
          condition: [ :check_a, ->(event) { event.payload[:route] == 'a' } ])
        bp.transition('start_step', 'route_event', 'path_b',
          condition: [ :check_b, ->(event) { event.payload[:route] == 'b' } ])
        bp.transition('start_step', 'route_event', 'default_path')
      end
    end

    before do
      multi_condition_business_process.start_listening_for_events
      kase.business_process_current_step = 'start_step'
      kase.save!
    end

    after do
      multi_condition_business_process.stop_listening_for_events
    end

    [
      [ 'route a matches first condition', { route: 'a' }, 'path_a' ],
      [ 'route b matches second condition', { route: 'b' }, 'path_b' ],
      [ 'no route matches, uses default', { route: 'c' }, 'default_path' ],
      [ 'nil route uses default', { route: nil }, 'default_path' ]
    ].each do |description, payload, expected_step|
      it description do
        Flex::EventManager.publish('route_event', { case_id: kase.id }.merge(payload))

        kase.reload
        expect(kase.business_process_current_step).to eq(expected_step)
      end
    end
  end
end
