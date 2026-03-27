# frozen_string_literal: true

require 'rails_helper'


RSpec.describe Strata::Rules::SampleRuleset do
  base_date = Date.new(2025, 7, 1)
  let(:rules) { described_class.new }

  describe '#submitted_within_60_days_of_start_date' do
    [
      [ 'submitted exactly 60 days before start date', base_date, (base_date - 60.days).beginning_of_day, true ],
      [ 'submitted 30 days before start date', base_date, (base_date - 30.days).beginning_of_day, true ],
      [ 'submitted 61 days before start date', base_date, (base_date - 61.days).beginning_of_day, false ],
      [ 'submitted after start date', base_date, base_date.to_time + 1.day, true ],
      [ 'submitted_at is nil', base_date, nil, nil ],
      [ 'start_date is nil', nil, base_date, nil ]
    ].each do |description, start_date, submitted_at, expected|
      context "when #{description}" do
        it "returns #{expected}" do
          expect(rules.submitted_within_60_days_of_start_date(submitted_at, start_date)).to eq(expected)
        end
      end
    end
  end
end
