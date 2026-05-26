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

  describe "#started?" do
    let(:task) { described_class.new("name", pages: [ first_name_page, last_name_page ]) }

    it "is false when no pages have data" do
      expect(task).not_to be_started(record)
    end

    it "is true when the first page has data" do
      record.first_name = "Mary"
      expect(task).to be_started(record)
    end

    it "is true when only a later page has data" do
      record.last_name = "Smith"
      expect(task).to be_started(record)
    end
  end

  describe "#completed?" do
    let(:task) { described_class.new("name", pages: [ first_name_page, last_name_page ]) }

    it "is false when no pages have data" do
      expect(task).not_to be_completed(record)
    end

    it "is false when only some pages are complete" do
      record.first_name = "Mary"
      expect(task).not_to be_completed(record)
    end

    it "is true when all pages are complete" do
      record.first_name = "Mary"
      record.last_name = "Smith"
      expect(task).to be_completed(record)
    end
  end

  describe "#path" do
    let(:task) { described_class.new("name", pages: [ first_name_page, last_name_page ]) }

    before do
      allow(first_name_page).to receive(:edit_path).and_return("first_name_path")
      allow(last_name_page).to receive(:edit_path).and_return("last_name_path")
    end

    it "returns the first page path when no pages have data" do
      expect(task.path(record)).to eq("first_name_path")
    end

    it "returns the first incomplete page path when in progress" do
      record.first_name = "Mary"
      expect(task.path(record)).to eq("last_name_path")
    end

    it "returns the first incomplete page path when only a later page has data" do
      record.last_name = "Smith"
      expect(task.path(record)).to eq("first_name_path")
    end

    it "returns the first page path when all pages are complete" do
      record.first_name = "Mary"
      record.last_name = "Smith"
      expect(task.path(record)).to eq("first_name_path")
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
