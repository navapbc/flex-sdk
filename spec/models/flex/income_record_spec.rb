require 'rails_helper'

module Flex
  RSpec.describe IncomeRecord, type: :model do
    describe 'factory pattern' do
      it 'creates YearQuarter-based subclass' do
        quarterly_wage = described_class[Flex::YearQuarter]

        expect(quarterly_wage.period_type).to eq(:year_quarter)
        expect(quarterly_wage.superclass).to eq(described_class)
      end

      it 'creates DateRange-based subclass' do
        annual_salary = described_class[Range]

        expect(annual_salary.period_type).to eq(:date_range)
        expect(annual_salary.superclass).to eq(described_class)
      end

      it 'raises error for unsupported period type' do
        expect { described_class[:invalid] }.to raise_error(ArgumentError, "Unsupported period type: invalid")
      end
    end

    describe 'YearQuarter subclass functionality' do
      let(:quarterly_wage_class) { described_class[Flex::YearQuarter] }

      it 'handles YearQuarter period assignment' do
        record = quarterly_wage_class.new(
          person_id: "123",
          amount: Flex::Money.new(5000),
          period: Flex::YearQuarter.new(2023, 2)
        )

        expect(record.person_id).to eq("123")
        expect(record.amount).to eq(Flex::Money.new(5000))
        expect(record.period).to eq(Flex::YearQuarter.new(2023, 2))
        expect(record.period_year).to eq(2023)
        expect(record.period_quarter).to eq(2)
      end
    end

    describe 'DateRange subclass functionality' do
      let(:annual_salary_class) { described_class[Range] }

      it 'handles DateRange period assignment' do
        start_date = Date.new(2023, 1, 1)
        end_date = Date.new(2023, 12, 31)

        record = annual_salary_class.new(
          person_id: "456",
          amount: Flex::Money.new(75000_00),
          period: start_date..end_date
        )

        expect(record.person_id).to eq("456")
        expect(record.amount).to eq(Flex::Money.new(75000_00))
        expect(record.period).to eq(start_date..end_date)
        expect(record.period_start).to eq(start_date)
        expect(record.period_end).to eq(end_date)
      end
    end

    describe 'base class' do
      it 'has nil period_type' do
        expect(described_class.period_type).to be_nil
      end
    end
  end
end
