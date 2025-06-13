# Rails generator for creating migrations with Flex attribute columns
module Flex
  module Generators
    # Generator that creates migrations for Flex attributes by mapping
    # each flex attribute type to its required database columns
    class MigrationGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("USAGE", __dir__)
      argument :attrs, type: :array, default: [], banner: "attribute:type attribute:type"

      def create_migration_file
        columns = []
        attrs.each do |attribute_string|
          name, type = attribute_string.split(":")
          type = type.to_sym

          case type
          when :address
            columns << "#{name}_street_line_1:string"
            columns << "#{name}_street_line_2:string"
            columns << "#{name}_city:string"
            columns << "#{name}_state:string"
            columns << "#{name}_zip_code:string"
          when :date_range
            columns << "#{name}_start:date"
            columns << "#{name}_end:date"
          when :document
            # Document attributes use ActiveStorage, no additional columns needed
            # The has_many_attached declaration will be added to the model
          when :memorable_date
            columns << "#{name}:date"
          when :money
            columns << "#{name}:integer"
          when :name
            columns << "#{name}_first:string"
            columns << "#{name}_middle:string"
            columns << "#{name}_last:string"
          when :tax_id
            columns << "#{name}:string"
          when :us_date
            columns << "#{name}:date"
          when :year_quarter
            columns << "#{name}_year:integer"
            columns << "#{name}_quarter:integer"
          else
            # Allow built-in types like string, integer, etc.
            columns << "#{name}:#{type}"
          end
        end

        generate("migration", name, *columns)
      end
    end
  end
end
