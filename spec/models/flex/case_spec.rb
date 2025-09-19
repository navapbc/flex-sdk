require 'rails_helper'

RSpec.describe Strata::Case, type: :model do
  let(:test_case) { TestCase.new }

  describe '#create_task' do
    before do
      stub_const('TestTask', Class.new(Strata::Task))
      stub_const('NotATask', Class.new)
    end

    it 'creates a task associated with the case' do
      description = Faker::Quote.yoda
      task = test_case.create_task(TestTask, description: description)

      expect(task).to be_a(TestTask)
      expect(task.case).to eq(test_case)
      expect(task.description).to eq(description)
      expect(task).to be_persisted
    end

    it 'accepts additional attributes' do
      due_date = Faker::Date.between(from: Date.today, to: Date.today + 1.year)
      description = Faker::Quote.yoda
      task = test_case.create_task(TestTask,
        description: description,
        due_on: due_date
      )

      expect(task.due_on).to eq(due_date)
      expect(task.description).to eq(description)
      expect(task).to be_persisted
    end

    it 'raises an error if task_class is not a subclass of Strata::Task' do
      expect {
        test_case.create_task(NotATask)
      }.to raise_error(ArgumentError, 'task_class must be Strata::Task or a subclass of it')
    end
  end

  describe 'status attribute' do
    it 'defaults to open' do
      expect(test_case.status).to eq('open')
    end

    it 'can be closed using the close method' do
      test_case.close
      expect(test_case.status).to eq('closed')
    end

    it 'can be reopened using the reopen method' do
      test_case.close
      test_case.reopen
      expect(test_case.status).to eq('open')
    end

    it 'cannot be directly modified from outside the class' do
      expect { test_case.status = :closed }.to raise_error(NoMethodError)
    end
  end
end
