# frozen_string_literal: true

require 'rails_helper'
require 'rake'

RSpec.describe 'strata:cases', type: :task do
  before do
    Rake.application.rake_require('tasks/strata_cases')
    Rake::Task.define_task(:environment)
  end

  describe 'migrate_business_process_current_step' do
    let(:task) { Rake::Task['strata:cases:migrate_business_process_current_step'] }

    after do
      task.reenable
    end

    describe 'argument validation' do
      [
        [ "case_class_name is missing", nil, "from_step", "to_step", /case_class_name is required/ ],
        [ "from_step_name is missing", "TestCase", nil, "to_step", /from_step_name is required/ ],
        [ "to_step_name is missing", "TestCase", "from_step", nil, /to_step_name is required/ ],
        [ "all arguments are missing", nil, nil, nil, /case_class_name, from_step_name, and to_step_name are required/ ]
      ].each do |description, case_class, from_step, to_step, error_pattern|
        it "raises error if #{description}" do
          expect {
            task.invoke(case_class, from_step, to_step)
          }.to raise_error(error_pattern)
        end
      end
    end

    describe 'successful migration' do
      let(:from_step_name) { Faker::Alphanumeric.alpha(number: rand(5..15)) }
      let(:to_step_name) { Faker::Alphanumeric.alpha(number: rand(5..15)) }
      let(:other_step_name) { Faker::Alphanumeric.alpha(number: rand(5..15)) }

      before do
        allow(Rails.logger).to receive(:info)
      end

      it 'updates all cases of the specified class with matching business_process_current_step' do
        case1 = create(:test_case)
        case1.update!(business_process_current_step: from_step_name)
        case2 = create(:test_case)
        case2.update!(business_process_current_step: from_step_name)
        case3 = create(:test_case)
        case3.update!(business_process_current_step: other_step_name)

        task.invoke("TestCase", from_step_name, to_step_name)

        expect(case1.reload.business_process_current_step).to eq(to_step_name)
        expect(case2.reload.business_process_current_step).to eq(to_step_name)
        expect(case3.reload.business_process_current_step).to eq(other_step_name)
      end

      it 'only updates the specified case type, not other case types' do
        test_case1 = create(:test_case)
        test_case1.update!(business_process_current_step: from_step_name)
        test_case2 = create(:test_case)
        test_case2.update!(business_process_current_step: from_step_name)

        passport_case = create(:passport_case)
        passport_case.update!(business_process_current_step: from_step_name)

        task.invoke("TestCase", from_step_name, to_step_name)

        expect(test_case1.reload.business_process_current_step).to eq(to_step_name)
        expect(test_case2.reload.business_process_current_step).to eq(to_step_name)
        expect(passport_case.reload.business_process_current_step).to eq(from_step_name)
      end

      it 'logs the number of updated cases' do
        test_case1 = create(:test_case)
        test_case1.update!(business_process_current_step: from_step_name)
        test_case2 = create(:test_case)
        test_case2.update!(business_process_current_step: from_step_name)

        task.invoke("TestCase", from_step_name, to_step_name)

        expect(Rails.logger).to have_received(:info).with(/Updated 2 TestCase record\(s\) from '#{from_step_name}' to '#{to_step_name}'/)
      end

      it 'handles cases where no records match from_step_name' do
        case1 = create(:test_case)
        case1.update!(business_process_current_step: other_step_name)

        task.invoke("TestCase", from_step_name, to_step_name)

        expect(case1.reload.business_process_current_step).to eq(other_step_name)
        expect(Rails.logger).to have_received(:info).with(/Updated 0 TestCase record\(s\) from '#{from_step_name}' to '#{to_step_name}'/)
      end

      it 'handles cases with nil business_process_current_step' do
        case1 = create(:test_case)
        case1.update!(business_process_current_step: nil)
        case2 = create(:test_case)
        case2.update!(business_process_current_step: from_step_name)

        task.invoke("TestCase", from_step_name, to_step_name)

        expect(case1.reload.business_process_current_step).to be_nil
        expect(case2.reload.business_process_current_step).to eq(to_step_name)
        expect(Rails.logger).to have_received(:info).with(/Updated 1 TestCase record\(s\) from '#{from_step_name}' to '#{to_step_name}'/)
      end
    end
  end
end
