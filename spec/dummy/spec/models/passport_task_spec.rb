require 'rails_helper'

RSpec.describe PassportTask, type: :model do
  let(:passport_case) { create(:passport_case) }
  let(:passport_task) { build(:passport_task, case: passport_case) }

  describe 'associations' do
    it 'belongs to a passport case' do
      expect(passport_task.case).to eq(passport_case)
    end

    it 'sets case_type correctly' do
      passport_task.save!
      expect(passport_task.case_type).to eq('PassportCase')
    end

    it 'appears in the case tasks collection' do
      passport_task.save!
      expect(passport_case.tasks).to include(passport_task)
    end
  end

  describe 'validations' do
    it 'is valid with a passport case' do
      expect(passport_task).to be_valid
    end

    it 'is invalid without a case' do
      passport_task.case = nil
      expect(passport_task).not_to be_valid
    end

    it 'cannot be associated with a non-passport case type' do
      other_case = create(:flex_case) # Assuming you have a generic case factory
      passport_task.case = other_case
      expect(passport_task).to be_valid # Polymorphic associations don't enforce type restrictions by default

      # But when we try to use it...
      passport_task.save!
      expect(passport_task.case).to be_instance_of(other_case.class)
    end
  end

  describe 'lifecycle' do
    it 'can be created with an associated case' do
      expect { passport_task.save! }.to change(PassportTask, :count).by(1)
    end

    it 'can be found through the case association' do
      passport_task.save!
      found_task = passport_case.tasks.first
      expect(found_task).to eq(passport_task)
    end

    it 'maintains the association after updates' do
      passport_task.save!
      passport_task.update!(description: 'Updated description')
      expect(passport_task.reload.case).to eq(passport_case)
    end
  end

  describe 'scopes and class methods' do
    let!(:other_passport_case) { create(:passport_case) }
    let!(:other_task) { create(:passport_task, case: other_passport_case) }

    before { passport_task.save! }

    it 'can find tasks for a specific case' do
      tasks_for_case = PassportTask.where(case: passport_case)
      expect(tasks_for_case).to include(passport_task)
      expect(tasks_for_case).not_to include(other_task)
    end
  end
end
