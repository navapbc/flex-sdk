# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Strata::AuditLine do
  describe 'associations' do
    it { is_expected.to belong_to(:subject).optional }
    it { is_expected.to belong_to(:actor).optional }
  end

  describe 'validations' do
    subject { build(:strata_audit_line) }

    it { is_expected.to validate_presence_of(:action) }
  end

  describe 'polymorphic subject' do
    let(:test_form) { create(:test_application_form) }

    it 'stores and retrieves polymorphic subject' do
      line = create(:strata_audit_line, subject: test_form)
      expect(line.subject).to eq(test_form)
      expect(line.subject_type).to eq('TestApplicationForm')
      expect(line.subject_id).to eq(test_form.id)
    end

    it 'allows nil subject' do
      line = build(:strata_audit_line, subject: nil)
      expect(line).to be_valid
      expect { line.save! }.not_to raise_error
    end
  end

  describe 'polymorphic actor' do
    let(:user) { create(:user) }

    it 'stores and retrieves an ActiveRecord actor' do
      line = create(:strata_audit_line, actor: user)
      expect(line.actor).to eq(user)
      expect(line.actor_type).to eq('User')
      expect(line.actor_id).to eq(user.id)
    end

    it 'allows nil actor' do
      line = build(:strata_audit_line, actor: nil)
      expect(line).to be_valid
      expect { line.save! }.not_to raise_error
      expect(line.actor_type).to be_nil
      expect(line.actor_id).to be_nil
    end
  end

  describe 'virtual actor write side' do
    it 'stores actor_type and leaves actor_id nil when given a virtual actor instance' do
      line = create(:strata_audit_line, actor: TestVirtualActor.new)
      expect(line.actor_type).to eq('TestVirtualActor')
      expect(line.actor_id).to be_nil
    end

    it 'treats a virtual actor class identically to an instance' do
      line = create(:strata_audit_line, actor: TestVirtualActor)
      expect(line.actor_type).to eq('TestVirtualActor')
      expect(line.actor_id).to be_nil
    end

    it 'clears actor_type and actor_id when reassigned to nil' do
      line = build(:strata_audit_line, actor: TestVirtualActor.new)
      line.actor = nil
      expect(line.actor_type).to be_nil
      expect(line.actor_id).to be_nil
    end

    it 'does not include a virtual actor as an AR record' do
      line = create(:strata_audit_line, actor: TestVirtualActor.new)
      expect(line.actor_id).to be_nil
      # Sanity: no constant lookup or DB hit happened — actor_id stays nil.
    end

    it 'accepts a VirtualActor::Instance returned from a previous read' do
      original = create(:strata_audit_line, actor: TestVirtualActor.new)
      instance = original.reload.actor
      expect(instance).to be_a(Strata::VirtualActor::Instance)

      copy = create(:strata_audit_line, actor: instance)
      expect(copy.actor_type).to eq('TestVirtualActor')
      expect(copy.actor_id).to be_nil
    end
  end

  describe 'data column' do
    it 'persists arbitrary jsonb payload and round-trips it' do
      payload = { 'changed_fields' => %w[status assignee_id], 'reason' => 'manual review' }
      line = create(:strata_audit_line, data: payload)
      expect(line.reload.data).to eq(payload)
    end

    it 'defaults data to {} when omitted' do
      line = described_class.create!(action: 'system.boot')
      expect(line.reload.data).to eq({})
    end
  end

  describe 'created_at' do
    it 'is set automatically on create' do
      line = create(:strata_audit_line)
      expect(line.created_at).to be_present
    end

    it 'has no updated_at attribute' do
      expect(described_class.column_names).not_to include('updated_at')
    end
  end

  describe 'immutability' do
    let(:line) { create(:strata_audit_line) }

    it 'is readonly once persisted' do
      expect(line.readonly?).to be true
    end

    it 'is not readonly when newly built' do
      expect(build(:strata_audit_line).readonly?).to be false
    end

    it 'raises when attempting to update an attribute' do
      expect { line.update!(action: 'tampered') }.to raise_error(ActiveRecord::ReadOnlyRecord)
    end

    it 'raises when attempting to destroy' do
      expect { line.destroy }.to raise_error(ActiveRecord::ReadOnlyRecord)
    end
  end

  describe 'scopes' do
    let(:test_form_alpha) { create(:test_application_form) }
    let(:test_form_bravo) { create(:test_application_form) }
    let(:user_alpha)      { create(:user) }
    let(:user_bravo)      { create(:user) }

    let!(:line_alpha_created) do
      create(:strata_audit_line, subject: test_form_alpha, actor: user_alpha,
                                  action: 'form.created', created_at: 3.days.ago)
    end
    let!(:line_alpha_updated) do
      create(:strata_audit_line, subject: test_form_alpha, actor: user_bravo,
                                  action: 'form.updated', created_at: 1.day.ago)
    end
    let!(:line_bravo_created) do
      create(:strata_audit_line, subject: test_form_bravo, actor: user_alpha,
                                  action: 'form.created', created_at: 2.days.ago)
    end

    describe '.for_subject' do
      it 'returns only lines for the given subject' do
        expect(described_class.for_subject(test_form_alpha))
          .to contain_exactly(line_alpha_created, line_alpha_updated)
      end

      it 'returns empty when subject has no lines' do
        new_form = create(:test_application_form)
        expect(described_class.for_subject(new_form)).to be_empty
      end
    end

    describe '.by_actor' do
      it 'returns only lines for the given actor' do
        expect(described_class.by_actor(user_alpha))
          .to contain_exactly(line_alpha_created, line_bravo_created)
      end
    end

    describe '.with_action' do
      it 'filters by action string' do
        expect(described_class.with_action('form.created'))
          .to contain_exactly(line_alpha_created, line_bravo_created)
      end

      it 'accepts symbol' do
        expect(described_class.with_action(:'form.updated'))
          .to contain_exactly(line_alpha_updated)
      end
    end

    describe '.latest_first' do
      it 'orders by created_at descending' do
        results = described_class.latest_first
        expect(results.first).to eq(line_alpha_updated)
        expect(results.last).to eq(line_alpha_created)
      end
    end

    describe 'chaining' do
      it 'composes for_subject with with_action' do
        expect(described_class.for_subject(test_form_alpha).with_action('form.created'))
          .to contain_exactly(line_alpha_created)
      end
    end
  end
end
