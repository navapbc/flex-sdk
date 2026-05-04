# frozen_string_literal: true

require 'rails_helper'

# This spec assumes Strata::Auditable is included in TestApplicationForm
# (analogous to how Strata::Determinable is included in ApplicationForm).
# If Auditable is included via a different host model, adjust the factory accordingly.
RSpec.describe Strata::Auditable do
  let(:test_form) { create(:test_application_form) }

  describe 'included behavior' do
    it 'adds an audit_lines association to the including model' do
      expect(test_form).to respond_to(:audit_lines)
    end

    it 'returns audit_lines whose subject is the host record' do
      line = create(:strata_audit_line, subject: test_form, action: 'form.created')
      unrelated_form = create(:test_application_form)
      create(:strata_audit_line, subject: unrelated_form, action: 'form.created')

      expect(test_form.audit_lines).to contain_exactly(line)
    end

    it 'returns an empty collection when no audit lines exist for the host' do
      expect(test_form.audit_lines).to be_empty
    end

    it 'does not auto-destroy audit lines when the host is destroyed' do
      # Audit lines are immutable history — they should outlive their subject
      # so that the trail of "what happened to this record" survives deletion.
      create(:strata_audit_line, subject: test_form, action: 'form.created')

      expect { test_form.destroy }.not_to change(Strata::AuditLine, :count)
    end
  end
end
