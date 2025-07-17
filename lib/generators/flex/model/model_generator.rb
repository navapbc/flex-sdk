require "rails/generators"
require "rails/generators/named_base"

module Flex
  module Generators
    # Rails model generator that supports Flex attributes like :name, :address, :money, etc.
    # Automatically includes Flex::Attributes and creates appropriate database migrations
    class ModelGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      argument :attributes, type: :array, default: [], banner: "field[:type][:index] field[:type][:index]"

      class_option :parent, type: :string, desc: "The parent class for the generated model"

      # Parse attributes manually to allow Flex types
      def initialize(args, *options)
        super
        parse_attributes!
      end

      def create_migration_file
        # Use flex:migration for all attributes since it supports both Flex and Rails types
        all_attrs = @parsed_attributes.map { |attr| "#{attr[:name]}:#{attr[:type]}" }

        if all_attrs.any?
          migration_name = "Create#{table_name.camelize}"
          generate("flex:migration", migration_name, *all_attrs)
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

      def rails_attributes
        @parsed_attributes.reject { |attr| flex_attribute_type?(attr[:type]) }
      end

      def has_rails_attributes?
        rails_attributes.any?
      end

      def parent_class_name
        options[:parent] || "ApplicationRecord"
      end
    end
  end
end
