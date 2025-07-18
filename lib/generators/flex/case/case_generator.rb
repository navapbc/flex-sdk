require "rails/generators"

module Flex
  module Generators
    # Generator for creating Flex::Case models with optional business process and application form integration
    class CaseGenerator < Rails::Generators::NamedBase
      argument :attributes, type: :array, default: [], banner: "field[:type][:index] field[:type][:index]"

      class_option :business_process_name, type: :string, desc: "Business process class name (optional)"
      class_option :application_form_name, type: :string, desc: "Application form class name (optional)"
      class_option :skip_business_process, type: :boolean, default: false, desc: "Skip business process generation check"
      class_option :skip_application_form, type: :boolean, default: false, desc: "Skip application form generation check"
      class_option :sti, type: :boolean, default: false, desc: "Add type column for single-table inheritance"

      def initialize(*args)
        super
        @case_name = format_case_name(name)
        @parsed_attributes = parse_attributes!
      end

      def create_case_model
        handle_business_process_generation unless options[:skip_business_process]
        handle_application_form_generation unless options[:skip_application_form]

        model_args = [ @case_name ]
        model_args.concat(all_attributes)
        model_args.concat([ "--parent", "Flex::Case" ])

        generate("flex:model", *model_args)
      end

      private

      def handle_business_process_generation
        bp_class = business_process_name
        unless bp_class.safe_constantize.present?
          if should_generate_business_process?(bp_class)
            base_name = extract_base_name_from_business_process(bp_class)
            generate("flex:business_process", base_name)
          end
        end
      end

      def handle_application_form_generation
        app_form_class = application_form_name
        unless app_form_class.safe_constantize.present?
          if should_generate_application_form?(app_form_class)
            base_name = extract_base_name_from_application_form(app_form_class)
            generate("flex:application_form", base_name)
          end
        end
      end


      def format_case_name(name)
        formatted = name.classify
        formatted.end_with?("Case") ? formatted : "#{formatted}Case"
      end

      def parse_attributes!
        attributes.map do |attribute|
          name, type = attribute.split(":")
          type ||= "string"
          "#{name}:#{type}"
        end
      end

      def all_attributes
        attrs = @parsed_attributes.dup
        attrs << "type:string" if options[:sti]
        attrs
      end

      def business_process_name
        options[:business_process_name] || "#{@case_name.gsub(/Case$/, "")}BusinessProcess"
      end

      def application_form_name
        options[:application_form_name] || "#{@case_name.gsub(/Case$/, "")}ApplicationForm"
      end

      def should_generate_business_process?(bp_class)
        yes?("Business process #{bp_class} does not exist. Generate it? (y/n)")
      end

      def should_generate_application_form?(app_form_class)
        yes?("Application form #{app_form_class} does not exist. Generate it? (y/n)")
      end

      def extract_base_name_from_business_process(bp_class)
        if options[:business_process_name]
          # If custom name provided, use it as-is (the generators expect the full class name)
          bp_class
        else
          # Default case: extract from case name
          @case_name.gsub(/Case$/, "")
        end
      end

      def extract_base_name_from_application_form(app_form_class)
        if options[:application_form_name]
          # If custom name provided, use it as-is (the generators expect the full class name)
          app_form_class
        else
          # Default case: extract from case name
          @case_name.gsub(/Case$/, "")
        end
      end
    end
  end
end
