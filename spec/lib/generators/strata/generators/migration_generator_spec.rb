require 'rails_helper'
require 'generators/strata/migration/migration_generator'
require 'fileutils'
require 'tmpdir'

RSpec.describe Strata::Generators::MigrationGenerator, type: :generator do
  let(:destination_root) { Dir.mktmpdir }
  let(:generator) { described_class.new([ name, *attrs ], options, destination_root: destination_root) }
  let(:name) { 'CreateTestRecords' }
  let(:attrs) { [] }
  let(:options) { {} }

  before do
    FileUtils.mkdir_p("#{destination_root}/db/migrate")
    allow(generator).to receive(:generate)
  end

  after do
    FileUtils.rm_rf(destination_root)
  end

  describe "attribute handling" do
    context "with built-in Rails types" do
      let(:attrs) { [ "name:string", "age:integer", "active:boolean" ] }

      it "passes through built-in types directly" do
        generator.create_migration_file
        expect(generator).to have_received(:generate).with(
          "migration",
          "CreateTestRecords",
          "name:string",
          "age:integer",
          "active:boolean"
        )
      end
    end

    context "with Strata attribute types" do
      let(:attrs) { [ "full_name:name", "home_address:address" ] }

      it "maps Strata types to their corresponding database columns" do
        generator.create_migration_file
        expect(generator).to have_received(:generate).with(
          "migration",
          "CreateTestRecords",
          "full_name_first:string",
          "full_name_middle:string",
          "full_name_last:string",
          "home_address_street_line_1:string",
          "home_address_street_line_2:string",
          "home_address_city:string",
          "home_address_state:string",
          "home_address_zip_code:string"
        )
      end
    end

    context "with mixed attribute types" do
      let(:attrs) { [ "full_name:name", "email:string", "birth_date:us_date" ] }

      it "handles both Strata and built-in types correctly" do
        generator.create_migration_file
        expect(generator).to have_received(:generate).with(
          "migration",
          "CreateTestRecords",
          "full_name_first:string",
          "full_name_middle:string",
          "full_name_last:string",
          "email:string",
          "birth_date:date"
        )
      end
    end

    context "with array option" do
      let(:attrs) { [ "tags:string:array", "categories:text:array" ] }

      it "creates jsonb columns for array attributes" do
        generator.create_migration_file
        expect(generator).to have_received(:generate).with(
          "migration",
          "CreateTestRecords",
          "tags:jsonb",
          "categories:jsonb"
        )
      end
    end

    context "with range option" do
      let(:attrs) { [ "period:us_date:range", "amount:money:range" ] }

      it "creates start and end columns for range attributes" do
        generator.create_migration_file
        expect(generator).to have_received(:generate).with(
          "migration",
          "CreateTestRecords",
          "period_start:date",
          "period_end:date",
          "amount_start:integer",
          "amount_end:integer"
        )
      end
    end

    context "with memorable_date type" do
      let(:attrs) { [ "reminder_date:memorable_date" ] }

      it "maps to date column" do
        generator.create_migration_file
        expect(generator).to have_received(:generate).with(
          "migration",
          "CreateTestRecords",
          "reminder_date:date"
        )
      end
    end

    context "with money type" do
      let(:attrs) { [ "amount:money" ] }

      it "maps to integer column" do
        generator.create_migration_file
        expect(generator).to have_received(:generate).with(
          "migration",
          "CreateTestRecords",
          "amount:integer"
        )
      end
    end

    context "with tax_id type" do
      let(:attrs) { [ "ssn:tax_id" ] }

      it "maps to string column" do
        generator.create_migration_file
        expect(generator).to have_received(:generate).with(
          "migration",
          "CreateTestRecords",
          "ssn:string"
        )
      end
    end

    context "with us_date type" do
      let(:attrs) { [ "due_date:us_date" ] }

      it "maps to date column" do
        generator.create_migration_file
        expect(generator).to have_received(:generate).with(
          "migration",
          "CreateTestRecords",
          "due_date:date"
        )
      end
    end

    context "with year_month type" do
      let(:attrs) { [ "reporting_period:year_month" ] }

      it "creates string column" do
        generator.create_migration_file
        expect(generator).to have_received(:generate).with(
          "migration",
          "CreateTestRecords",
          "reporting_period:string"
        )
      end
    end

    context "with year_quarter type" do
      let(:attrs) { [ "fiscal_period:year_quarter" ] }

      it "creates string column" do
        generator.create_migration_file
        expect(generator).to have_received(:generate).with(
          "migration",
          "CreateTestRecords",
          "fiscal_period:string"
        )
      end
    end
  end

  describe "complex scenarios" do
    let(:attrs) { [
      "person_name:name",
      "contact_address:address",
      "tags:array",
      "valid_period:us_date:range",
      "amounts:money:array",
      "fiscal_quarter:year_quarter",
      "reporting_period:year_month"
    ]}

    it "handles complex combinations of types and options correctly" do
      generator.create_migration_file
      expect(generator).to have_received(:generate).with(
        "migration",
        "CreateTestRecords",
        "person_name_first:string",
        "person_name_middle:string",
        "person_name_last:string",
        "contact_address_street_line_1:string",
        "contact_address_street_line_2:string",
        "contact_address_city:string",
        "contact_address_state:string",
        "contact_address_zip_code:string",
        "tags:jsonb",
        "valid_period_start:date",
        "valid_period_end:date",
        "amounts:jsonb",
        "fiscal_quarter:string",
        "reporting_period:string"
      )
    end
  end
end
