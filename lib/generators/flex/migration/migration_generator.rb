# Rails generator for creating migrations with Flex attribute columns
module Flex
  module Generators
    # Generator that creates migrations for Flex attributes by mapping
    # each flex attribute type to its required database columns
    class MigrationGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("USAGE", __dir__)
      argument :attrs, type: :array, default: [], banner: "attribute:type attribute:type attribute:type:array attribute:type:range"

      def create_migration_file
        columns = []
        attrs.each do |attribute_string|
          attribute_parts = attribute_string.split(":")
          name = attribute_parts.first
          type = attribute_parts[1]&.to_sym
          option = attribute_parts.last.to_sym

          columns += get_columns_for_attribute(name, type, option)
        end

        generate("migration", name, *columns)
      end

      private

      def get_columns_for_attribute(name, type, option = nil)
        return [ "#{name}:jsonb" ] if option == :array

        if option == :range
          return get_columns_for_attribute("#{name}_start", type) +
                 get_columns_for_attribute("#{name}_end", type)
        end

        case type
        when :address
          [
            "#{name}_street_line_1:string",
            "#{name}_street_line_2:string",
            "#{name}_city:string",
            "#{name}_state:string",
            "#{name}_zip_code:string"
          ]
        when :array
          [ "#{name}:jsonb" ]
        when :memorable_date
          [ "#{name}:date" ]
        when :money
          [ "#{name}:integer" ]
        when :name
          [
            "#{name}_first:string",
            "#{name}_middle:string",
            "#{name}_last:string"
          ]
        when :tax_id
          [ "#{name}:string" ]
        when :us_date
          [ "#{name}:date" ]
        when :year_month
          [ "#{name}:string" ]
        when :year_quarter
          [ "#{name}:string" ]
        else
          # Allow built-in types like string, integer, etc.
          [ "#{name}:#{type}" ]
        end
      end
    end
  end
end
