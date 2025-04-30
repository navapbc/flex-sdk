require 'rails_helper'

RSpec.describe Flex::Task, type: :model do
  describe 'status attribute' do
    let(:task) { described_class.new }

    it 'does not allow status to be modified directly' do
      expect { task.status = :completed }.to raise_error(NoMethodError)
    end

    it 'allows status to be modified via mark_completed method' do
      task.mark_completed
      expect(task.status).to eq('completed')
    end
  end
end
