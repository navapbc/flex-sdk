# frozen_string_literal: true

FactoryBot.define do
  factory :strata_audit_line, class: 'Strata::AuditLine' do
    action { 'test.event' }
    subject { nil }
    actor { nil }
    data { {} }
  end
end
