require 'rails_helper'

RSpec.describe Flex::SystemProcess do
  describe '#initialize' do
    let(:valid_name) { "Test Process" }
    let(:valid_callback) { ->(kase) { true } }

    it 'initializes successfully with valid arguments' do
      expect {
        described_class.new(valid_name, valid_callback)
      }.not_to raise_error
    end

    it 'raises ArgumentError when callback does not respond to :call' do
      invalid_callback = Object.new

      expect {
        described_class.new(valid_name, invalid_callback)
      }.to raise_error(ArgumentError, "`callback` must respond to :call")
    end

    it 'raises ArgumentError when callback is nil' do
      expect {
        described_class.new(valid_name, nil)
      }.to raise_error(ArgumentError, "`callback` must respond to :call")
    end
  end
end
