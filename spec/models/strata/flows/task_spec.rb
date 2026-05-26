# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Strata::Flows::Task do
  before do
    test_model_class = Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :first_name, :string
      attribute :last_name, :string
      validates :first_name, presence: true, on: :first_name
      validates :last_name, presence: true, on: :last_name
    end

    stub_const("TestModel", test_model_class)
  end

  let(:first_name_page) { Strata::Flows::QuestionPage.new("first_name") }
  let(:last_name_page) { Strata::Flows::QuestionPage.new("last_name") }
  let(:record) { TestModel.new }

  describe "an unstarted task" do
    let(:task) { described_class.new("name", pages: [ first_name_page ]) }

    it "is not started or completed" do
      expect(task).not_to be_started(record)
      expect(task).not_to be_completed(record)
    end

    it "returns the first page path" do
      allow(first_name_page).to receive(:edit_path).and_return("edit_path")
      expect(task.path(record)).to eq("edit_path")
    end
  end

  describe "a started task" do
    let(:task) { described_class.new("name", pages: [ first_name_page, last_name_page ]) }

    before { record.first_name = "Mary" }

    it "is started but not completed" do
      expect(task).to be_started(record)
      expect(task).not_to be_completed(record)
    end

    it "returns the first incomplete page path" do
      allow(last_name_page).to receive(:edit_path).and_return("edit_path")
      expect(task.path(record)).to eq("edit_path")
    end
  end

  describe "a completed task" do
    let(:task) { described_class.new("name", pages: [ first_name_page ]) }

    before { record.first_name = "Mary" }

    it "is started and completed" do
      expect(task).to be_started(record)
      expect(task).to be_completed(record)
    end

    it "returns the first page path" do
      allow(first_name_page).to receive(:edit_path).and_return("edit_path")
      expect(task.path(record)).to eq("edit_path")
    end
  end

  describe "a task with data on a later page but not the first page" do
    let(:task) { described_class.new("name", pages: [ first_name_page, last_name_page ]) }

    before { record.last_name = "Smith" }

    it "is started" do
      expect(task).to be_started(record)
    end

    it "returns the first incomplete page path" do
      allow(first_name_page).to receive(:edit_path).and_return("edit_path")
      expect(task.path(record)).to eq("edit_path")
    end
  end

  describe "#dependencies_met?" do
    let(:complete_task) { described_class.new(:personal_info) }
    let(:incomplete_task) { described_class.new(:contact_info) }
    let(:flow) { SampleFlow.new(build_stubbed(:sample_application_form)) }

    before do
      allow(complete_task).to receive(:completed?).and_return(true)
      allow(incomplete_task).to receive(:completed?).and_return(false)
    end

    context "with no depends_on" do
      let(:task) { described_class.new(:review) }

      it "returns true" do
        allow(flow).to receive(:tasks).and_return([ complete_task, incomplete_task, task ])
        expect(task.dependencies_met?(flow)).to be true
      end
    end

    context "with depends_on: :all" do
      let(:task) { described_class.new(:review, depends_on: :all) }

      it "returns true when all other tasks are complete" do
        allow(flow).to receive(:tasks).and_return([ complete_task, task ])
        expect(task.dependencies_met?(flow)).to be true
      end

      it "returns false when any other task is incomplete" do
        allow(flow).to receive(:tasks).and_return([ complete_task, incomplete_task, task ])
        expect(task.dependencies_met?(flow)).to be false
      end
    end

    context "with depends_on: [:specific_tasks]" do
      let(:task) { described_class.new(:review, depends_on: [ :personal_info ]) }

      it "returns true when named dependencies are complete" do
        allow(flow).to receive(:tasks).and_return([ complete_task, incomplete_task, task ])
        expect(task.dependencies_met?(flow)).to be true
      end

      it "returns false when a named dependency is incomplete" do
        task_with_dep = described_class.new(:review, depends_on: [ :contact_info ])
        allow(flow).to receive(:tasks).and_return([ complete_task, incomplete_task, task_with_dep ])
        expect(task_with_dep.dependencies_met?(flow)).to be false
      end
    end
  end
end
