# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Strata::Flows::TaskEvaluator do
  before do
    test_model_class = Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :first_name, :string
    end

    stub_const("TestModel", test_model_class)
  end

  let(:record) { TestModel.new }
  let(:task) do
    Strata::Flows::Task.new("personal_information", pages: [
      Strata::Flows::QuestionPage.new("first_name"),
      Strata::Flows::QuestionPage.new("middle_name", if: ->(record) { record.first_name === "John" }),
      Strata::Flows::QuestionPage.new("last_name")
    ])
  end

  let(:eval) { described_class.new(task, record, current_page_idx) }

  describe "#current_page" do
    let(:current_page_idx) { 2 }

    it "returns the current page" do
      expect(eval.current_page.name).to eq("last_name")
    end
  end

  describe "#prev_path" do
    describe "on the first page" do
      let(:current_page_idx) { 0 }

      it "returns nil" do
        expect(eval.prev_path).to be_nil
      end
    end

    describe "on other pages" do
      let(:current_page_idx) { 2 }

      it "returns the previous path" do
        record.first_name = "John"
        allow(task.pages[1]).to receive(:edit_path).and_return("edit_path")
        expect(eval.prev_path).to eq("edit_path")
      end

      it "ignores unnecessary pages" do
        allow(task.pages[0]).to receive(:edit_path).and_return("edit_path")
        expect(eval.prev_path).to eq("edit_path")
      end
    end
  end

  describe "#update_path" do
    let(:current_page_idx) { 0 }

    it "returns the update path for the current page" do
      allow(task.pages[0]).to receive(:update_path).and_return("update_path")
      expect(eval.update_path).to eq("update_path")
    end
  end

  describe "#next_path" do
    describe "on the last page" do
      let(:current_page_idx) { 2 }

      it "returns nil" do
        expect(eval.next_path).to be_nil
      end
    end

    describe "on other pages" do
      let(:current_page_idx) { 0 }

      it "returns the next path" do
        record.first_name = "John"
        allow(task.pages[1]).to receive(:edit_path).and_return("edit_path")
        expect(eval.next_path).to eq("edit_path")
      end

      it "ignores unnecessary pages" do
        allow(task.pages[2]).to receive(:edit_path).and_return("edit_path")
        expect(eval.next_path).to eq("edit_path")
      end
    end
  end
end
