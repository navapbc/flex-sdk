require 'rails_helper'

module Flex
  module Rules
    RSpec.describe PaidLeaveRules do
      base_date = Date.new(2025, 7, 1)
      
      subject(:engine) { described_class.new(facts) }

      describe 'submitted_within_60_days_of_leave_start' do
        [
          ['submitted exactly 60 days before leave start', base_date, (base_date - 60.days).beginning_of_day, true],
          ['submitted 30 days before leave start', base_date, (base_date - 30.days).beginning_of_day, true],
          ['submitted 61 days before leave start', base_date, (base_date - 61.days).beginning_of_day, false],
          ['submitted after leave start', base_date, base_date.to_time + 1.day, true],
          ['submitted_at is nil', base_date, nil, nil],
          ['leave_starts_on is nil', nil, base_date, nil]
        ].each do |description, leave_starts_on, submitted_at, expected|
          context "when #{description}" do
            let(:facts) do
              {
                leave_starts_on: leave_starts_on,
                submitted_at: submitted_at
              }
            end

            it "returns #{expected}" do
              result = engine.evaluate(:submitted_within_60_days_of_leave_start)
              expect(result.value).to eq(expected)
              expect(result.reasons).to contain_exactly(
                have_attributes(name: :submitted_at, value: submitted_at),
                have_attributes(name: :leave_starts_on, value: leave_starts_on)
              )
            end
          end
        end
      end
    end
  end
end
