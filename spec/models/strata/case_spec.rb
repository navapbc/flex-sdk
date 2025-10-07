# frozen_string_literal: true

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

  describe '.for_event scope' do
    let(:test_case) { create(:test_case) }

    context 'when event has case_id' do
      it 'returns cases with matching case_id' do
        event = { payload: { case_id: test_case.id } }
        expect(TestCase.for_event(event).to_a).to eq([ test_case ])
      end

      it 'raises ArgumentError when case_id is nil' do
        event = { payload: { case_id: nil } }
        expect {
          TestCase.for_event(event)
        }.to raise_error(ArgumentError, 'case_id cannot be nil')
      end
    end

    context 'when event has application_form_id' do
      it 'returns cases with matching application_form_id' do
        event = { payload: { application_form_id: test_case.application_form_id } }
        expect(TestCase.for_event(event).to_a).to eq([ test_case ])
      end

      it 'raises ArgumentError when application_form_id is nil' do
        event = { payload: { application_form_id: nil } }
        expect {
          TestCase.for_event(event)
        }.to raise_error(ArgumentError, 'application_form_id cannot be nil')
      end
    end

    context 'when event has neither case_id nor application_form_id' do
      it 'returns none' do
        event = { payload: {} }
        expect(TestCase.for_event(event)).to eq(TestCase.none)
      end
    end
  end
end
