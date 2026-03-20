# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Strata::Flows::ApplicationFormFlow do
  before do
    test_model_class = Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :applicant_name_first, :string
      attribute :applicant_name_last, :string
      attribute :date_of_birth, :string
      attribute :leave_type, :string

      validates :applicant_name_first, presence: true, on: :name
      validates :applicant_name_last, presence: true, on: :name
      validates :date_of_birth, presence: true, on: :date_of_birth
      validates :leave_type, presence: true, on: :leave_type
    end

    test_flow_class = Class.new do
      include Strata::Flows::ApplicationFormFlow
      task :personal_information do
        question_page :name, fields: [ :applicant_name_first, :applicant_name_last ]
        question_page :date_of_birth
      end

      task :leave_details do
        question_page :leave_type
        question_page :supporting_documents, if: ->(app) { app.leave_type === "medical" }
      end

      end_page :review
    end

    stub_const("TestModel", test_model_class)
    stub_const("TestFlow", test_flow_class)
  end

  it "parses the task structure correctly" do
    expect(TestFlow.tasks.length).to eq(2)
    expect(TestFlow.tasks.map(&:name)).to eq([ :personal_information, :leave_details ])
    expect(TestFlow.tasks[0].pages.map(&:name)).to eq([ :name, :date_of_birth ])
    expect(TestFlow.tasks[1].pages.map(&:name)).to eq([ :leave_type, :supporting_documents ])

    expect(TestFlow.contexts).to eq([
      :name,
      :date_of_birth,
      :leave_type,
      :supporting_documents
    ])
    expect(TestFlow.end_pathname).to eq(:review)
  end

  describe "#find_page_and_task_by_action" do
    it "returns the page and task based on the action name" do
      page, task = TestFlow.find_page_and_task_by_action(TestModel.new, "edit_name")
      expect(page.name).to eq(:name)
      expect(task.task.name).to eq(:personal_information)
      expect(task.current_page_idx).to eq(0)
    end
  end

  describe "task dependencies" do
    before do
      flow_with_deps = Class.new do
        include Strata::Flows::ApplicationFormFlow

        task :personal_information do
          question_page :name, fields: [ :applicant_name_first, :applicant_name_last ]
        end

        task :leave_details, depends_on: [ :personal_information ] do
          question_page :leave_type
        end

        end_page :review
      end

      stub_const("FlowWithDeps", flow_with_deps)
    end

    it "stores depends_on on the task" do
      leave_task = FlowWithDeps.tasks.find { |t| t.name == :leave_details }
      expect(leave_task.depends_on).to eq([ :personal_information ])
    end

    it "stores nil depends_on when not specified" do
      personal_task = FlowWithDeps.tasks.find { |t| t.name == :personal_information }
      expect(personal_task.depends_on).to be_nil
    end

    describe "#task_dependencies_met?" do
      let(:record) { TestModel.new }
      let(:flow) { FlowWithDeps.new(record) }

      it "returns true for tasks with no dependencies" do
        personal_task = flow.tasks.find { |t| t.name == :personal_information }
        expect(flow.task_dependencies_met?(personal_task)).to be true
      end

      it "returns false when dependent tasks are incomplete" do
        leave_task = flow.tasks.find { |t| t.name == :leave_details }
        expect(flow.task_dependencies_met?(leave_task)).to be false
      end

      it "returns true when named dependencies are complete" do
        record.applicant_name_first = "Jane"
        record.applicant_name_last = "Doe"

        leave_task = flow.tasks.find { |t| t.name == :leave_details }
        expect(flow.task_dependencies_met?(leave_task)).to be true
      end
    end

    describe "invalid depends_on references" do
      it "raises an error when task depends_on references a non-existent task" do
        expect {
          Class.new do
            include Strata::Flows::ApplicationFormFlow

            task :personal_information do
              question_page :name, fields: [ :applicant_name_first ]
            end

            task :review, depends_on: [ :nonexistent_task ] do
              question_page :date_of_birth
            end
          end
        }.to raise_error(ArgumentError, /nonexistent_task/)
      end
    end
  end
end
