require 'rails_helper'
require 'generators/flex/migration/migration_generator'

module Flex
  module Generators
    RSpec.describe MigrationGenerator, type: :generator do
      destination File.expand_path("../../../../tmp", __dir__)

      before do
        prepare_destination
      end

      context "with a name attribute" do
        it "creates a migration with name fields" do
          run_generator %w(AddPersonNameFieldsToTestRecords person_name:name)

          # expect(destination_root).to have_structure {
          #   directory "db" do
          #     directory "migrate" do
          #       migration "add_person_name_fields" do
          #         contains "add_column :person_name_first, :string"
          #         contains "add_column :person_name_middle, :string"
          #         contains "add_column :person_name_last, :string"
          #       end
          #     end
          #   end
          # }
        end
      end

      #   context "with an address attribute" do
      #     arguments %w(AddMailingAddress mailing:address)

      #     it "creates a migration with address fields" do
      #       # run_generator
      #       expect(destination_root).to have_structure {
      #         directory "db" do
      #           directory "migrate" do
      #             migration "add_mailing_address" do
      #               contains "add_column :mailing_street_line_1, :string"
      #               contains "add_column :mailing_street_line_2, :string"
      #               contains "add_column :mailing_city, :string"
      #               contains "add_column :mailing_state, :string"
      #               contains "add_column :mailing_zip_code, :string"
      #             end
      #           end
      #         end
      #       }
      #     end
      #   end

      #   context "with a money attribute" do
      #     arguments %w(AddPaymentAmount amount:money)

      #     it "creates a migration with an integer column" do
      #       # run_generator
      #       expect(destination_root).to have_structure {
      #         directory "db" do
      #           directory "migrate" do
      #             migration "add_payment_amount" do
      #               contains "add_column :amount, :integer"
      #             end
      #           end
      #         end
      #       }
      #     end
      #   end

      #   context "with a year_quarter attribute" do
      #     arguments %w(AddReportingPeriod period:year_quarter)

      #     it "creates a migration with year and quarter fields" do
      #       # run_generator
      #       expect(destination_root).to have_structure {
      #         directory "db" do
      #           directory "migrate" do
      #             migration "add_reporting_period" do
      #               contains "add_column :period_year, :integer"
      #               contains "add_column :period_quarter, :integer"
      #             end
      #           end
      #         end
      #       }
      #     end
      #   end

      #   context "with multiple attributes" do
      #     arguments %w(AddApplicantDetails name:name dob:memorable_date ssn:tax_id)

      #     it "creates a migration with all the required fields" do
      #       # run_generator
      #       expect(destination_root).to have_structure {
      #         directory "db" do
      #           directory "migrate" do
      #             migration "add_applicant_details" do
      #               contains "add_column :name_first, :string"
      #               contains "add_column :name_middle, :string"
      #               contains "add_column :name_last, :string"
      #               contains "add_column :dob, :date"
      #               contains "add_column :ssn, :string"
      #             end
      #           end
      #         end
      #       }
      #     end
      #   end

      #   context "with an invalid attribute type" do
      #     it "raises an ArgumentError" do
      #       expect {
      #         # run_generator %w(add_invalid_field field:invalid)
      #       }.to raise_error(ArgumentError, "Unsupported flex attribute type: invalid")
      #     end
      #   end
      # end
    end
  end
end
