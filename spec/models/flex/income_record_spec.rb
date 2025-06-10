require 'rails_helper'
require 'temporary_tables'

module Flex
  RSpec.describe IncomeRecord, type: :model do
    describe 'IncomeRecord[YearQuarter]' do
      include TemporaryTables::Methods

      temporary_table :quarterly_wages do |t|
        t.string :person_id
        t.integer :amount
        t.integer :period_year
        t.integer :period_quarter
        t.timestamps
      end

      before do
        stub_const("QuarterlyWage", described_class[Flex::YearQuarter])
      end

      describe '#period_type' do
        it 'returns :year_quarter' do
          expect(QuarterlyWage.period_type).to eq(:year_quarter)
        end
      end

      describe '#create' do
        it 'creates an instance of an IncomeRecord with a YearQuarter period' do
          record = QuarterlyWage.create(
            person_id: "123",
            amount: Flex::Money.new(5000),
            period: Flex::YearQuarter.new(2023, 2)
          )

          record = QuarterlyWage.find(record.id)

          expect(record.person_id).to eq("123")
          expect(record.amount).to eq(Flex::Money.new(5000))
          expect(record.period).to eq(Flex::YearQuarter.new(2023, 2))
        end
      end
    end

    describe 'IncomeRecord[Range]' do
      include TemporaryTables::Methods

      temporary_table :weekly_wages do |t|
        t.string :person_id
        t.integer :amount
        t.date :period_start
        t.date :period_end
        t.timestamps
      end

      before do
        stub_const("WeeklyWage", described_class[Range])
      end

      describe '#period_type' do
        it 'returns :date_range' do
          expect(WeeklyWage.period_type).to eq(:date_range)
        end
      end

      describe '#create' do
        it 'creates an instance of an IncomeRecord with a DateRange period' do
          start_date = Date.new(2023, 1, 1)
          end_date = Date.new(2023, 1, 7)
          record = WeeklyWage.create(
            person_id: "456",
            amount: Flex::Money.new(1000),
            period: start_date..end_date
          )
          record = WeeklyWage.find(record.id)
          expect(record.person_id).to eq("456")
          expect(record.amount).to eq(Flex::Money.new(1000))
          expect(record.period).to eq(start_date..end_date)
        end
      end
    end

    describe 'IncomeRecord[:invalid]' do
      it 'raises an error for unsupported period type' do
        expect { described_class[:invalid] }.to raise_error(ArgumentError, "Unsupported period type: invalid")
      end
    end

    describe 'base class' do
      describe '#period_type' do
        it 'returns nil' do
          expect(described_class.period_type).to be_nil
        end
      end
    end
  end
end
