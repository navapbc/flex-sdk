# frozen_string_literal: true

require 'rails_helper'
require 'ostruct'
require_relative '../../../lib/tasks/strata_task_helpers'

RSpec.describe StrataTaskHelpers do
  let(:test_class) do
    Class.new do
      extend StrataTaskHelpers
    end
  end

  describe '.fetch_required_args!' do
    context 'when all required arguments are present' do
      it 'returns the values of the required arguments' do
        args = OpenStruct.new(arg1: 'value1', arg2: 'value2', arg3: 'value3')

        result = test_class.fetch_required_args!(args, :arg1, :arg2, :arg3)

        expect(result).to eq([ 'value1', 'value2', 'value3' ])
      end

      it 'returns a single value when only one argument is required' do
        args = OpenStruct.new(arg1: 'value1')

        result = test_class.fetch_required_args!(args, :arg1)

        expect(result).to eq([ 'value1' ])
      end
    end

    context 'when one required argument is missing (nil)' do
      it 'raises an error with singular verb' do
        args = OpenStruct.new(arg1: 'value1', arg2: nil)

        expect {
          test_class.fetch_required_args!(args, :arg1, :arg2)
        }.to raise_error(/arg2 is required/)
      end
    end

    context 'when one required argument is an empty string' do
      it 'raises an error treating empty string as blank' do
        args = OpenStruct.new(arg1: 'value1', arg2: '')

        expect {
          test_class.fetch_required_args!(args, :arg1, :arg2)
        }.to raise_error(/arg2 is required/)
      end
    end

    context 'when multiple required arguments are missing' do
      it 'raises an error with plural verb' do
        args = OpenStruct.new(arg1: nil, arg2: nil, arg3: 'value3')

        expect {
          test_class.fetch_required_args!(args, :arg1, :arg2, :arg3)
        }.to raise_error(/arg1 and arg2 are required/)
      end
    end

    context 'when all required arguments are missing' do
      it 'raises an error listing all arguments' do
        args = OpenStruct.new(arg1: nil, arg2: nil, arg3: nil)

        expect {
          test_class.fetch_required_args!(args, :arg1, :arg2, :arg3)
        }.to raise_error(/arg1, arg2, and arg3 are required/)
      end
    end

    context 'when a single argument is missing' do
      it 'raises an error with singular verb' do
        args = OpenStruct.new(only_arg: nil)

        expect {
          test_class.fetch_required_args!(args, :only_arg)
        }.to raise_error(/only_arg is required/)
      end
    end
  end
end
