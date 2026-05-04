# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Strata::AuditLog do
  let(:user)        { create(:user) }
  let(:other_user)  { create(:user) }
  let(:test_form)   { create(:test_application_form) }

  describe '.record' do
    it 'returns a Strata::AuditLog instance' do
      result = described_class.record(actor: user) { |log| log.add_line(action: 'noop') }
      expect(result).to be_a(described_class)
    end

    it 'yields a log object the caller can append lines to' do
      yielded = nil
      described_class.record(actor: user) { |log| yielded = log }
      expect(yielded).to be_a(described_class)
    end

    it 'persists every appended line' do
      expect {
        described_class.record(actor: user) do |log|
          log.add_line(action: 'a', subject: test_form, data: { i: 1 })
          log.add_line(action: 'b', subject: test_form, data: { i: 2 })
        end
      }.to change(Strata::AuditLine, :count).by(2)
    end

    it 'exposes the persisted lines via .lines after the block returns' do
      result = described_class.record(actor: user) do |log|
        log.add_line(action: 'a', subject: test_form)
        log.add_line(action: 'b', subject: test_form)
      end

      expect(result.lines.length).to eq(2)
      expect(result.lines).to all(be_persisted)
      expect(result.lines.map(&:action)).to eq(%w[a b])
    end

    it 'wraps appended lines in a database transaction' do
      allow(ActiveRecord::Base).to receive(:transaction).and_call_original

      described_class.record(actor: user) { |log| log.add_line(action: 'wrapped') }

      expect(ActiveRecord::Base).to have_received(:transaction)
    end

    context 'when the block raises an exception' do
      it 'rolls back all appended lines' do
        expect {
          begin
            described_class.record(actor: user) do |log|
              log.add_line(action: 'before-raise', subject: test_form)
              raise StandardError, 'boom'
            end
          rescue StandardError
            # expected
          end
        }.not_to change(Strata::AuditLine, :count)
      end

      it 'propagates the exception' do
        expect {
          described_class.record(actor: user) do |log|
            log.add_line(action: 'x')
            raise StandardError, 'boom'
          end
        }.to raise_error(StandardError, 'boom')
      end

      it 'rolls back caller writes inside the same transaction' do
        existing_form = create(:test_application_form)

        expect {
          begin
            described_class.record(actor: user) do |log|
              existing_form.update!(updated_at: 1.year.from_now)
              log.add_line(action: 'updated', subject: existing_form)
              raise StandardError, 'boom'
            end
          rescue StandardError
            # expected
          end
        }.not_to(change { existing_form.reload.updated_at })
      end
    end

    context 'when the block raises ActiveRecord::Rollback' do
      it 'silently rolls back appended lines' do
        expect {
          described_class.record(actor: user) do |log|
            log.add_line(action: 'discarded')
            raise ActiveRecord::Rollback
          end
        }.not_to change(Strata::AuditLine, :count)
      end

      it 'does not propagate the exception' do
        expect {
          described_class.record(actor: user) do |log|
            log.add_line(action: 'discarded')
            raise ActiveRecord::Rollback
          end
        }.not_to raise_error
      end
    end

    context 'with actor handling' do
      it 'uses the block-level default actor for appended lines' do
        result = described_class.record(actor: user) do |log|
          log.add_line(action: 'a')
          log.add_line(action: 'b')
        end

        expect(result.lines.map(&:actor)).to all(eq(user))
      end

      it 'allows per-line override of actor' do
        result = described_class.record(actor: user) do |log|
          log.add_line(action: 'a')
          log.add_line(action: 'b', actor: other_user)
        end

        expect(result.lines[0].actor).to eq(user)
        expect(result.lines[1].actor).to eq(other_user)
      end

      it 'allows nil actor when no default is set and none passed' do
        result = described_class.record do |log|
          log.add_line(action: 'system.event')
        end

        expect(result.lines.first.actor).to be_nil
      end
    end

    context 'with data handling' do
      it 'persists the supplied jsonb payload' do
        result = described_class.record(actor: user) do |log|
          log.add_line(action: 'a', data: { 'foo' => 'bar' })
        end

        expect(result.lines.first.reload.data).to eq({ 'foo' => 'bar' })
      end

      it 'coerces nil data to {}' do
        result = described_class.record(actor: user) do |log|
          log.add_line(action: 'a', data: nil)
        end

        expect(result.lines.first.reload.data).to eq({})
      end

      it 'defaults data to {} when omitted' do
        result = described_class.record(actor: user) do |log|
          log.add_line(action: 'a')
        end

        expect(result.lines.first.reload.data).to eq({})
      end
    end

    context 'with subject handling' do
      it 'allows nil subject (system events)' do
        result = described_class.record(actor: user) do |log|
          log.add_line(action: 'system.boot')
        end

        expect(result.lines.first.subject).to be_nil
      end

      it 'persists polymorphic subject correctly' do
        result = described_class.record(actor: user) do |log|
          log.add_line(action: 'form.viewed', subject: test_form)
        end

        line = result.lines.first
        expect(line.subject).to eq(test_form)
        expect(line.subject_type).to eq('TestApplicationForm')
        expect(line.subject_id).to eq(test_form.id)
      end
    end

    context 'when validation fails' do
      it 'raises when action is missing' do
        expect {
          described_class.record(actor: user) { |log| log.add_line(action: nil) }
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'rolls back the entire transaction on a validation failure mid-block' do
        expect {
          begin
            described_class.record(actor: user) do |log|
              log.add_line(action: 'first')
              log.add_line(action: nil) # validation failure -> raises
            end
          rescue ActiveRecord::RecordInvalid
            # expected
          end
        }.not_to change(Strata::AuditLine, :count)
      end
    end
  end

  describe '.write!' do
    it 'creates a single Strata::AuditLine row' do
      expect {
        described_class.write!(action: 'user.signed_in', actor: user)
      }.to change(Strata::AuditLine, :count).by(1)
    end

    it 'returns the persisted AuditLine' do
      line = described_class.write!(action: 'user.signed_in', actor: user)
      expect(line).to be_a(Strata::AuditLine)
      expect(line).to be_persisted
    end

    it 'persists action, actor, subject, and data' do
      line = described_class.write!(
        action: 'form.viewed',
        actor: user,
        subject: test_form,
        data: { 'ip' => '127.0.0.1' }
      )

      expect(line.action).to eq('form.viewed')
      expect(line.actor).to eq(user)
      expect(line.subject).to eq(test_form)
      expect(line.data).to eq({ 'ip' => '127.0.0.1' })
    end

    it 'allows nil actor and nil subject' do
      line = described_class.write!(action: 'system.startup')
      expect(line.actor).to be_nil
      expect(line.subject).to be_nil
    end

    it 'coerces nil data to {}' do
      line = described_class.write!(action: 'a', data: nil)
      expect(line.data).to eq({})
    end

    it 'raises ActiveRecord::RecordInvalid when action is missing' do
      expect { described_class.write!(action: nil) }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
