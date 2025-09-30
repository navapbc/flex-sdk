require "rails/generators"

module Strata
  module Generators
    # Generator for creating Strata::Case models with optional business process and application form integration
    class CaseGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      argument :attributes, type: :array, default: [], banner: "field[:type][:index] field[:type][:index]"

      class_option :"business-process", type: :string, desc: "Business process class name (optional)"
      class_option :"application-form", type: :string, desc: "Application form class name (optional)"
      class_option :"skip-business-process", type: :boolean, default: false, desc: "Skip business process generation check"
      class_option :"skip-application-form", type: :boolean, default: false, desc: "Skip application form generation check"
      class_option :"staff-controller", type: :boolean, default: false, desc: "Generate StaffController if it doesn't exist"
      class_option :sti, type: :boolean, default: false, desc: "Add type column for single-table inheritance"

      def initialize(*args)
        super
        @case_name = format_case_name(name)
        @parsed_attributes = parse_attributes!
      end

      def create_case_model
        model_args = [ @case_name ]
        model_args.concat(all_attributes)
        model_args.concat([ "--parent", "Strata::Case" ])

        generate("strata:model", *model_args)

        handle_business_process_generation unless options[:"skip-business-process"]
        handle_application_form_generation unless options[:"skip-application-form"]

        handle_staff_controller_generation
        create_case_controller
        create_case_views
        update_routes
        create_locale_file
      end

      private

      def handle_business_process_generation
        bp_class = business_process_name
        unless bp_class.safe_constantize.present?
          if should_generate_business_process?(bp_class)
            base_name = extract_base_name_from_business_process(bp_class)

            generate("strata:business_process", base_name, "--skip-application-form")
          end
        end
      end

      def handle_application_form_generation
        app_form_class = application_form_name
        unless app_form_class.safe_constantize.present?
          if should_generate_application_form?(app_form_class)
            base_name = extract_base_name_from_application_form(app_form_class)
            generate("strata:application_form", base_name)
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

        # Merge base attributes from Strata::Case, with base attributes taking precedence
        base_attrs = Strata::Case.base_attributes_for_generator

        # Get base attribute names for conflict detection
        base_attr_names = base_attrs.map { |attr| attr.split(":").first }

        # Start with base attributes (they always come first and take precedence)
        result = base_attrs.dup

        # Add user attributes that don't conflict with base attributes
        attrs.each do |attr|
          name = attr.split(":").first
          # Only add user attribute if it doesn't conflict with base attributes
          unless base_attr_names.include?(name)
            result << attr
          end
        end

        result
      end

      def business_process_name
        options[:"business-process"] || "#{@case_name.gsub(/Case$/, "")}BusinessProcess"
      end

      def application_form_name
        options[:"application-form"] || "#{@case_name.gsub(/Case$/, "")}ApplicationForm"
      end

      def should_generate_business_process?(bp_class)
        options[:"business-process"].present? || yes?("Business process #{bp_class} does not exist. Generate it? (y/n)")
      end

      def should_generate_application_form?(app_form_class)
        options[:"application-form"].present? || yes?("Application form #{app_form_class} does not exist. Generate it? (y/n)")
      end

      def extract_base_name_from_business_process(bp_class)
        if options[:"business-process"]
          # If custom name provided, use it as-is (the generators expect the full class name)
          bp_class
        else
          # Default case: extract from case name
          @case_name.gsub(/Case$/, "")
        end
      end

      def extract_base_name_from_application_form(app_form_class)
        if options[:"application-form"]
          # If custom name provided, use it as-is (the generators expect the full class name)
          app_form_class
        else
          # Default case: extract from case name
          @case_name.gsub(/Case$/, "")
        end
      end

      def handle_staff_controller_generation
        unless "::StaffController".safe_constantize.present?
          if options[:"staff-controller"] || yes?("StaffController does not exist. Generate it? (y/n)")
            generate("strata:staff")
          end
        end
      end

      def create_case_controller
        template "controller.rb", "app/controllers/#{file_name.pluralize}_controller.rb"
      end

      def create_case_views
        template "views/index.html.erb", "app/views/#{file_name.pluralize}/index.html.erb"
        template "views/show.html.erb", "app/views/#{file_name.pluralize}/show.html.erb"
        template "views/documents.html.erb", "app/views/#{file_name.pluralize}/documents.html.erb"
        template "views/tasks.html.erb", "app/views/#{file_name.pluralize}/tasks.html.erb"
        template "views/notes.html.erb", "app/views/#{file_name.pluralize}/notes.html.erb"
      end

      def update_routes
        route_definition = <<~ROUTES
          scope path: "/staff" do
            resources :#{file_name.pluralize}, only: [ :index, :show ] do
              collection do
                get :closed
              end
          #{'    '}
              member do
                get :tasks
                get :documents
                get :notes
              end
            end
          end
        ROUTES

        route route_definition
      end

      def create_locale_file
        template "locales/en.yml", "config/locales/views/#{file_name.pluralize}/en.yml"
        template "locales/es-US.yml", "config/locales/views/#{file_name.pluralize}/es-US.yml"
      end
    end
  end
end
