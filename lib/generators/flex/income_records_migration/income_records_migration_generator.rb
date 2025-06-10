module Flex
  module Generators
    # Generator that creates migrations for income records with specified period types.
    # Supports year_quarter or date_range period types.
    #
    # @example Generate migration for quarterly income records
    #   rails generate flex:income_records_migration CreateIncomeRecords year_quarter
    #
    # @example Generate migration for date range income records
    #   rails generate flex:income_records_migration CreateIncomeRecords date_range
    #
    class IncomeRecordsMigrationGenerator < Rails::Generators::NamedBase
      argument :period_type, type: :string, default: "date_range", banner: "period_type"

      def create_migration_file
        columns = [ "person_id:string", "amount:money" ]

        raise ArgumentError, "Unsupported period type: #{period_type}. Use 'year_quarter' or 'date_range'" if ![ "year_quarter", "date_range" ].include?(period_type)

        columns << "period:#{period_type}"

        generate("flex:migration", name, *columns)
      end
    end
  end
end
