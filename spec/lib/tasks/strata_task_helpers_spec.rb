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
    end

    describe 'error handling for missing arguments' do
      test_cases = [
        {
          description: 'when one required argument is missing (nil)',
          args: { arg1: 'value1', arg2: nil },
          required_args: [:arg1, :arg2],
          expected_error: /arg2 is required/
        },
        {
          description: 'when one required argument is an empty string',
          args: { arg1: 'value1', arg2: '' },
          required_args: [:arg1, :arg2],
          expected_error: /arg2 is required/
        },
        {
          description: 'when multiple required arguments are missing',
          args: { arg1: nil, arg2: nil, arg3: 'value3' },
          required_args: [:arg1, :arg2, :arg3],
          expected_error: /arg1 and arg2 are required/
        },
        {
          description: 'when all required arguments are missing',
          args: { arg1: nil, arg2: nil, arg3: nil },
          required_args: [:arg1, :arg2, :arg3],
          expected_error: /arg1, arg2, and arg3 are required/
        },
        {
          description: 'when a single argument is missing',
          args: { only_arg: nil },
          required_args: [:only_arg],
          expected_error: /only_arg is required/
        }
      ]

      test_cases.each do |test_case|
        context test_case[:description] do
          it 'raises an error with appropriate message' do
            args = OpenStruct.new(test_case[:args])

            expect {
              test_class.fetch_required_args!(args, *test_case[:required_args])
            }.to raise_error(test_case[:expected_error])
          end
        end
      end
    end
  end
end
