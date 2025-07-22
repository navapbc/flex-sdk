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
        model_args = [ @case_name ]
        model_args.concat(all_attributes)
        model_args.concat([ "--parent", "Flex::Case" ])

        Rails.logger.debug "Creating case model with arguments: #{model_args.join(' ')}"
        generate("flex:model", *model_args)

        handle_business_process_generation unless options[:skip_business_process]
        handle_application_form_generation unless options[:skip_application_form]
      end

      private

      def handle_business_process_generation
        bp_class = business_process_name
        Rails.logger.debug "Checking for business process class: #{bp_class}"
        unless bp_class.safe_constantize.present?
          Rails.logger.debug "Business process class #{bp_class} does not exist."
          if should_generate_business_process?(bp_class)
            base_name = extract_base_name_from_business_process(bp_class)
            Rails.logger.debug "User requested to generate business process. Generating business process class: #{bp_class} utilizing base name: #{base_name}"

            generate("flex:business_process", base_name, "--skip_generating_application_form")
          end
        end
      end

      def handle_application_form_generation
        app_form_class = application_form_name
        Rails.logger.debug "Checking for application form class: #{app_form_class}"
        unless app_form_class.safe_constantize.present?
          Rails.logger.debug "Application form class #{app_form_class} does not exist."
          if should_generate_application_form?(app_form_class)
            base_name = extract_base_name_from_application_form(app_form_class)
            Rails.logger.debug "User requested to generate application form. Generating application form class: #{app_form_class} utilizing base name: #{base_name}"
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
