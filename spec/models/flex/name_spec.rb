require 'rails_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe Flex::Name do
  let(:first) { "Jane" }
  let(:middle) { "Adams" }
  let(:last) { "Doe" }
  let(:name) { described_class.new(first:, middle:, last:) }
  let(:same_name) { described_class.new(first:, middle:, last:) }
  let(:different_name) { described_class.new(first: "John", middle:, last:) }

  describe '#initialize' do
    it 'sets first, middle, and last names' do
      expect(name.first).to eq("Jane")
      expect(name.middle).to eq("Adams")
      expect(name.last).to eq("Doe")
    end
  end

  describe '#<=>' do
    it 'returns 0 for equal names' do
      expect(name <=> same_name).to eq(0)
    end

    it 'returns -1 for names that sort before' do
      expect(name <=> different_name).to eq(-1)
    end

    it 'returns 1 for names that sort after' do
      expect(different_name <=> name).to eq(1)
    end
  end

  describe '#persisted?' do
    it 'returns false' do
      expect(name).not_to be_persisted
    end
  end

  describe '#full_name' do
    it 'returns properly formatted full name' do
      expect(name.full_name).to eq('Jane Adams Doe')
    end
  end
end
# rubocop:enable RSpec/TooManyMemoizedHelpers
