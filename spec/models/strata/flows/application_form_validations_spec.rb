# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Strata::Flows::ApplicationFormValidations do
  before do
    test_flow_class = Class.new do
      include Strata::Flows::ApplicationFormFlow
      task :personal_information do
        question_page :name
        question_page :date_of_birth
      end
    end

    stub_const("TestFlow", test_flow_class)

    test_model_class = Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes
      include ActiveModel::Validations
      include Strata::Flows::ApplicationFormValidations

      validate_flow TestFlow

      attribute :name, :string
      attribute :date_of_birth, :string

      validates :name, presence: true, on: :name
      validates :date_of_birth, presence: true, on: :date_of_birth
    end

    stub_const("TestModel", test_model_class)
  end

  let(:record) { TestModel.new(date_of_birth: "123") }

  it "validates based on validation contexts" do
    expect(record).not_to be_valid(TestModel::Flow::NAME)
    expect(record).to be_valid(TestModel::Flow::DATE_OF_BIRTH)
  end

  it "validates on submit" do
    expect(record).not_to be_valid(:submit)

    record.name = "me"
    expect(record).to be_valid(:submit)
  end
end
