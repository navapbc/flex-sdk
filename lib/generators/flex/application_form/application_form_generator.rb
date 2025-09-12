require "rails/generators"

module Flex
  module Generators
    # Generator for creating Flex application form models
    class ApplicationFormGenerator < Rails::Generators::NamedBase
      desc "Creates a new Flex application form model"

      class_option :parent, type: :string, desc: "The parent class for the generated model"

      def create_application_form
        # Transform name to ensure ApplicationForm suffix
        form_name = name.end_with?("ApplicationForm") ? name : "#{name}ApplicationForm"

        # Set parent option default
        parent = options[:parent].blank? ? "Flex::ApplicationForm" : options[:parent]

        # Get base application form attributes from the ApplicationForm class
        base_attributes = Flex::ApplicationForm.base_attributes_for_generator

        # Build arguments for the Rails model generator
        model_args = [ form_name ]

        # Merge base attributes with any additional arguments (attributes)
        attribute_args = base_attributes.dup
        attribute_args.concat(args) if args.any?
        model_args.concat(attribute_args)
        model_args.concat([ "--parent", parent ])

        # Call the Rails model generator with transformed args
        generate("flex:model", *model_args)
      end
    end
  end
end
