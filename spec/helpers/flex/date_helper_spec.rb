require 'rails_helper'

RSpec.describe Flex::DateHelper, type: :helper do
  describe '#local_en_us' do
    it 'formats a date in US locale (MM/DD/YYYY)' do
      date = Date.new(2023, 1, 15)

      expect(helper.local_en_us(date)).to eq('01/15/2023')
    end

    it 'returns nil if date is nil' do
      expect(helper.local_en_us(nil)).to be_nil
    end
  end

  describe '#time_since_epoch' do
    it 'returns the number of seconds since epoch for a date' do
      date = Date.new(2023, 1, 15)
      expected = date.to_time.to_i

      expect(helper.time_since_epoch(date)).to eq(expected)
    end

    it 'returns nil if date is nil' do
      expect(helper.time_since_epoch(nil)).to be_nil
    end
  end
end
