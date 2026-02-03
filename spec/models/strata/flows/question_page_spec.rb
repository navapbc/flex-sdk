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
      expect(page).to be_needed(record)
    end

    it "is completed based on the page name" do
      expect(page).not_to be_completed(record)

      record.first_name = "Mary"
      expect(page).to be_completed(record)
    end

    it "returns the correct pathnames" do
      expect(page.edit_pathname).to eq("edit_first_name")
      expect(page.update_pathname).to eq("update_first_name")
    end
  end

  describe "with conditional if" do
    let(:page) { described_class.new("first_name", if: ->(record) { record.first_name.nil? }) }

    it "is needed if conditional is true" do
      expect(page).to be_needed(record)
    end

    it "skips the page if conditional is false" do
      record.first_name = "Minnie"
      expect(page).not_to be_needed(record)
    end
  end

  describe "with explicit fields" do
    let(:page) { described_class.new("name", fields: [ :first_name, :last_name ]) }

    it "uses the passed in fields" do
      expect(page.fields).to eq([ :first_name, :last_name ])
    end
  end
end
