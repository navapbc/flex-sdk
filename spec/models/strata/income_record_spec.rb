require 'rails_helper'
require 'temporary_tables'

module Strata
  RSpec.describe IncomeRecord, type: :model do
    describe 'IncomeRecord[YearQuarter]' do
      include TemporaryTables::Methods

      temporary_table :quarterly_wages do |t|
        t.string :person_id
        t.integer :amount
        t.string :period
        t.timestamps
      end

      before do
        stub_const("QuarterlyWage", described_class[Strata::YearQuarter])
      end

      describe '#period_type' do
        it 'returns :year_quarter' do
          expect(QuarterlyWage.period_type).to eq(:year_quarter)
        end
      end

      describe '#create' do
        it 'creates an instance of an IncomeRecord with a YearQuarter period' do
          person_id = SecureRandom.uuid
          amount = build(:money)
          period = build(:year_quarter)

          record = QuarterlyWage.create(person_id:, amount:, period:)
          record = QuarterlyWage.find(record.id)

          expect(record.person_id).to eq(person_id)
          expect(record.amount).to eq(amount)
          expect(record.period).to eq(period)
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
          person_id = SecureRandom.uuid
          amount = build(:money)
          period = build(:date_range)
          record = WeeklyWage.create(person_id:, amount:, period:)
          record = WeeklyWage.find(record.id)
          expect(record.person_id).to eq(person_id)
          expect(record.amount).to eq(amount)
          expect(record.period).to eq(period)
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
