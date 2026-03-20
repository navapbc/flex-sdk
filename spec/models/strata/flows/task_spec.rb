# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Strata::Flows::Task do
  before do
    test_model_class = Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :first_name, :string
      validates :first_name, presence: true, on: :first_name
    end

    stub_const("TestModel", test_model_class)
  end

  let(:incomplete_page) { Strata::Flows::QuestionPage.new("first_name") }
  let(:complete_page) { Strata::Flows::QuestionPage.new("last_name") }
  let(:record) { TestModel.new }

  describe "an unstarted task" do
    let(:task) { described_class.new("name", pages: [ incomplete_page ]) }

    it "is not started or completed" do
      expect(task).not_to be_started(record)
      expect(task).not_to be_completed(record)
    end

    it "returns the first page path" do
      allow(incomplete_page).to receive(:edit_path).and_return("edit_path")
      expect(task.path(record)).to eq("edit_path")
    end
  end

  describe "a started task" do
    let(:task) { described_class.new("name", pages: [ complete_page, incomplete_page ]) }

    it "is started but not completed" do
      expect(task).to be_started(record)
      expect(task).not_to be_completed(record)
    end

    it "returns the first incomplete page path" do
      allow(incomplete_page).to receive(:edit_path).and_return("edit_path")
      expect(task.path(record)).to eq("edit_path")
    end
  end

  describe "a completed task" do
    let(:task) { described_class.new("name", pages: [ complete_page ]) }

    it "is started and completed" do
      expect(task).to be_started(record)
      expect(task).to be_completed(record)
    end

    it "returns the first page path" do
      allow(complete_page).to receive(:edit_path).and_return("edit_path")
      expect(task.path(record)).to eq("edit_path")
    end
  end

  describe "#dependencies_met?" do
    let(:page_a) { Strata::Flows::QuestionPage.new("first_name") }
    let(:page_b) { Strata::Flows::QuestionPage.new("last_name") }

    let(:task_a) { described_class.new(:personal_info, pages: [ page_b ]) }
    let(:task_b) { described_class.new(:contact_info, pages: [ incomplete_page ]) }

    def build_flow(all_tasks)
      flow_class = Class.new do
        include Strata::Flows::ApplicationFormFlow
      end
      flow_class.instance_variable_set(:@tasks, all_tasks)
      flow_class.new(record)
    end

    context "with no depends_on" do
      let(:task) { described_class.new(:review, pages: [ page_a ]) }

      it "returns true" do
        flow = build_flow([ task_a, task_b, task ])
        expect(task.dependencies_met?(flow)).to be true
      end
    end

    context "with depends_on: :all" do
      let(:task) { described_class.new(:review, depends_on: :all, pages: [ page_a ]) }

      it "returns true when all other tasks are complete" do
        flow = build_flow([ task_a, task ])
        expect(task.dependencies_met?(flow)).to be true
      end

      it "returns false when any other task is incomplete" do
        flow = build_flow([ task_a, task_b, task ])
        expect(task.dependencies_met?(flow)).to be false
      end
    end

    context "with depends_on: [:specific_tasks]" do
      let(:task) { described_class.new(:review, depends_on: [ :personal_info ], pages: [ page_a ]) }

      it "returns true when named dependencies are complete" do
        flow = build_flow([ task_a, task_b, task ])
        expect(task.dependencies_met?(flow)).to be true
      end

      it "returns false when a named dependency is incomplete" do
        task_with_dep = described_class.new(:review, depends_on: [ :contact_info ], pages: [ page_a ])
        flow = build_flow([ task_a, task_b, task_with_dep ])
        expect(task_with_dep.dependencies_met?(flow)).to be false
      end
    end
  end
end
