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
        parent = options[:parent] || "Flex::ApplicationForm"

        # Build arguments for the Rails model generator
        model_args = [ form_name, "--parent", parent ]

        # Pass through any additional arguments (attributes)
        model_args.concat(args) if args.any?

        # Call the Rails model generator with transformed args
        generate("model", *model_args)
      end
    end
  end
end
