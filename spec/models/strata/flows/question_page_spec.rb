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

  describe "#attributes" do
    before do
      test_model_class = Class.new(ActiveRecord::Base) do
        self.table_name = "test_records"
        include Strata::Attributes

        strata_attribute :applicant_name, :name
        strata_attribute :home_address, :address
        strata_attribute :date_of_birth, :memorable_date
        strata_attribute :weekly_wage, :money
        strata_attribute :tax_id, :tax_id
        strata_attribute :adopted_on, :us_date
        strata_attribute :period, :us_date, range: true
      end

      stub_const("StrataTestModel", test_model_class)
    end

    let(:record) { StrataTestModel.new }

    it "expands name fields into component columns" do
      page = described_class.new("name", fields: [ :applicant_name ])
      expect(page.attributes(record.class)).to eq([
        :applicant_name_first, :applicant_name_middle, :applicant_name_last, :applicant_name_suffix
      ])
    end

    it "expands address fields into component columns" do
      page = described_class.new("address", fields: [ :home_address ])
      expect(page.attributes(record.class)).to eq([
        :home_address_street_line_1, :home_address_street_line_2,
        :home_address_city, :home_address_state, :home_address_zip_code
      ])
    end

    it "expands memorable_date fields into a multi-parameter hash" do
      page = described_class.new("dob", fields: [ :date_of_birth ])
      expect(page.attributes(record.class)).to eq([
        { date_of_birth: [ :month, :day, :year ] }
      ])
    end

    it "expands range fields into start and end columns" do
      page = described_class.new("period", fields: [ :period ])
      expect(page.attributes(record.class)).to eq([
        :period_start, :period_end
      ])
    end

    it "passes through single-column strata fields unchanged" do
      page = described_class.new("wage", fields: [ :weekly_wage ])
      expect(page.attributes(record.class)).to eq([ :weekly_wage ])
    end

    it "passes through non-strata fields unchanged" do
      page = described_class.new("misc", fields: [ :some_plain_field ])
      expect(page.attributes(record.class)).to eq([ :some_plain_field ])
    end

    it "handles a mix of strata and non-strata fields" do
      page = described_class.new("mixed", fields: [ :applicant_name, :tax_id, :date_of_birth ])
      expect(page.attributes(record.class)).to eq([
        :applicant_name_first, :applicant_name_middle, :applicant_name_last, :applicant_name_suffix,
        :tax_id,
        { date_of_birth: [ :month, :day, :year ] }
      ])
    end
  end
end
