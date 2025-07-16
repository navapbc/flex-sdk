require "rails/generators"
require "rails/generators/named_base"

module Flex
  module Generators
    # Rails model generator that supports Flex attributes like :name, :address, :money, etc.
    # Automatically includes Flex::Attributes and creates appropriate database migrations
    class ModelGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      argument :attributes, type: :array, default: [], banner: "field[:type][:index] field[:type][:index]"

      class_option :migration, type: :boolean
      class_option :timestamps, type: :boolean
      class_option :parent, type: :string, desc: "The parent class for the generated model"
      class_option :indexes, type: :boolean, default: true, desc: "Add indexes for references and belongs_to columns"
      class_option :primary_key_type, type: :string, desc: "The type for primary key"

      # Parse attributes manually to allow Flex types
      def initialize(args, *options)
        super
        parse_attributes!
      end

      def create_migration_file
        return unless options.fetch(:migration, true) && options[:parent] != "false"

        flex_attrs = []
        rails_attrs = []

        @parsed_attributes.each do |attr|
          if flex_attribute_type?(attr[:type])
            flex_attrs << "#{attr[:name]}:#{attr[:type]}"
          else
            rails_attrs << "#{attr[:name]}:#{attr[:type]}"
          end
        end

        # Generate Flex migration for Flex attributes
        if flex_attrs.any?
          migration_name = "Create#{table_name.camelize}"
          generate("flex:migration", migration_name, *flex_attrs)
        end

        # Generate standard Rails migration for regular attributes using the standard generator
        if rails_attrs.any?
          generate("active_record:migration", "Create#{table_name.camelize}", *rails_attrs)
        end
      end

      def create_model_file
        template "model.rb.tt", File.join("app/models", class_path, "#{file_name}.rb")
      end

      private

      def parse_attributes!
        @parsed_attributes = attributes.map do |attribute|
          name, type = attribute.split(":")
          type ||= "string"
          { name: name, type: type.to_sym }
        end
      end

      def flex_attribute_type?(type)
        [ :name, :address, :money, :memorable_date, :us_date, :tax_id, :year_quarter ].include?(type.to_sym)
      end

      def has_flex_attributes?
        flex_attributes.any?
      end

      def flex_attributes
        @parsed_attributes.select { |attr| flex_attribute_type?(attr[:type]) }
      end

      def parent_class_name
        if options[:parent]
          options[:parent]
        else
          "ApplicationRecord"
        end
      end

      def migration_number
        @migration_number ||= Time.now.utc.strftime("%Y%m%d%H%M%S")
      end

      def db_migrate_path
        "db/migrate"
      end

      def table_name
        @table_name ||= class_name.underscore.pluralize
      end
    end
  end
end
