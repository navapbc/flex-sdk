require 'rails_helper'

RSpec.describe <%= @task_name %>, type: :model do
  describe "inheritance" do
    it "inherits from <%= @parent_class %>" do
      expect(described_class.superclass).to eq(<%= @parent_class %>)
    end
  end
  
  describe "creation" do
    let(:test_case) { create(:test_case) }
    
    it "can be created with valid attributes" do
      task = described_class.from_case(test_case)
      expect(task).to be_valid
    end
  end
end
