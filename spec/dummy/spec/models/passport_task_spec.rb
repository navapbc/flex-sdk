# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PassportTask, type: :model do
  let(:passport_case) { create(:passport_case) }
  let(:passport_task) { passport_case.create_task(described_class) }

  describe 'associations' do
    it 'belongs to a passport case' do
      expect(passport_task.case).to eq(passport_case)
    end

    it 'sets case_type correctly' do
      expect(passport_task.case_type).to eq('PassportCase')
    end

    it 'appears in the case tasks collection' do
      expect(passport_case.tasks).to include(passport_task)
    end
  end

  describe 'validations' do
    it 'is valid with a passport case' do
      expect(passport_task).to be_valid
    end
  end

  describe 'lifecycle' do
    it 'can be found through the case association' do
      passport_task.save!
      found_task = passport_case.tasks.first
      expect(found_task).to eq(passport_task)
    end
  end

  describe 'scopes and class methods' do
    let(:other_passport_case) { create(:passport_case) }
    let(:other_task) { other_passport_case.create_task(described_class) }

    it 'can find tasks for a specific case' do
      tasks_for_case = described_class.where(case: passport_case)
      expect(tasks_for_case).to include(passport_task)
      expect(tasks_for_case).not_to include(other_task)
    end
  end
end
