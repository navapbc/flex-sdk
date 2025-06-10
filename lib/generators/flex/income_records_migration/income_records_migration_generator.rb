module Flex
  module Generators
    # Generator that creates migrations for income records with specified period types.
    # Supports year_quarter, date_range, or both period types.
    #
    # @example Generate migration for quarterly income records
    #   rails generate flex:income_records_migration CreateIncomeRecords year_quarter
    #
    # @example Generate migration for date range income records
    #   rails generate flex:income_records_migration CreateIncomeRecords date_range
    #
    class IncomeRecordsMigrationGenerator < Rails::Generators::NamedBase
      argument :period_type, type: :string, default: "year_quarter", banner: "period_type"

      def create_migration_file
        columns = [ "person_id:string", "amount:integer" ]

        case period_type.to_sym
        when :year_quarter
          columns << "period_year:integer"
          columns << "period_quarter:integer"
        when :date_range
          columns << "period_start:date"
          columns << "period_end:date"
        when :both
          columns << "period_year:integer"
          columns << "period_quarter:integer"
          columns << "period_start:date"
          columns << "period_end:date"
        else
          raise ArgumentError, "Unsupported period type: #{period_type}. Use 'year_quarter', 'date_range', or 'both'"
        end

        generate("migration", name, *columns)
      end
    end
  end
end
