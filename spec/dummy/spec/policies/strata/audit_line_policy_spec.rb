# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Strata::AuditLinePolicy do
  let(:user)       { create(:user) }
  let(:other_user) { create(:user) }

  describe 'Scope' do
    subject(:resolved) { described_class::Scope.new(user, Strata::AuditLine.all).resolve }

    let!(:own_form)   { create(:test_application_form, user_id: user.id) }
    let!(:other_form) { create(:test_application_form, user_id: other_user.id) }

    let!(:visible_line) do
      create(:strata_audit_line, subject: own_form, action: 'form.created')
    end

    let!(:hidden_line) do
      create(:strata_audit_line, subject: other_form, action: 'form.created')
    end

    let!(:system_line) do
      create(:strata_audit_line, subject: nil, action: 'system.boot')
    end

    it 'includes audit lines whose subject the user owns' do
      expect(resolved).to include(visible_line)
    end

    it 'excludes audit lines whose subject the user does not own' do
      expect(resolved).not_to include(hidden_line)
    end

    it 'includes system events (lines with no subject)' do
      expect(resolved).to include(system_line)
    end

    it 'raises when initialized without a user' do
      expect {
        described_class::Scope.new(nil, Strata::AuditLine.all)
      }.to raise_error(Pundit::NotAuthorizedError)
    end

    context 'with an audit line for an unknown subject type' do
      let!(:unknown_subject_line) do
        Strata::AuditLine.create!(
          action: 'mystery.event',
          subject_type: 'SomeUnauditedClass',
          subject_id: SecureRandom.uuid
        )
      end

      it 'excludes audit lines for subject types the policy does not know about' do
        expect(resolved).not_to include(unknown_subject_line)
      end
    end
  end
end
