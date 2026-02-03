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
end
