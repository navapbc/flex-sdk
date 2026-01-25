# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Strata::Flows::QuestionPage do
  before do
    test_model_class = Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :first_name, :string
      validates :first_name, presence: true, on: :first_name
    end

    stub_const("TestModel", test_model_class)
  end

  let(:record) { TestModel.new }

  describe "with only required attributes" do
    let(:page) { described_class.new("first_name") }

    it "uses the provided name as the set of fields" do
      expect(page.name).to eq("first_name")
      expect(page.fields).to eq([ :first_name ])
    end

    it "is always needed" do
      expect(page.needed?(record)).to be_truthy
    end

    it "is completed based on the page name" do
      expect(page.completed?(record)).to be_falsey

      record.first_name = "Mary"
      expect(page.completed?(record)).to be_truthy
    end

    it "returns the correct pathnames" do
      expect(page.edit_pathname).to eq("edit_first_name")
      expect(page.update_pathname).to eq("update_first_name")

      allow(page).to receive("edit_first_name_test_model_path").and_return("edit_path")
      allow(page).to receive("update_first_name_test_model_path").and_return("update_path")

      expect(page.edit_path).to eq("edit_path")
      expect(page.update_path).to eq("update_path")
    end
  end

  describe "with conditional if" do
    let(:page) { described_class.new("first_name", if: ->(record) { record.first_name.nil? }) }

    it "is needed if conditional is true" do
      expect(page.needed?(record)).to be_truthy
    end

    it "skips the page if conditional is false" do
      record.first_name = "Minnie"
      expect(page.needed?(record)).to be_falsey
    end
  end

  describe "with explicit fields" do
    let(:page) { described_class.new("name", fields: [ :first_name, :last_name ]) }

    it "uses the passed in fields" do
      expect(page.fields).to eq([ :first_name, :last_name ])
    end
  end
end
