require "rails/generators"

module Strata
  module Generators
    # Generator for creating Flex application form models
    class ApplicationFormGenerator < Rails::Generators::NamedBase
      desc "Creates a new Flex application form model"

      class_option :parent, type: :string, desc: "The parent class for the generated model"

      def create_application_form
        # Transform name to ensure ApplicationForm suffix
        form_name = name.end_with?("ApplicationForm") ? name : "#{name}ApplicationForm"

        # Set parent option default
        parent = options[:parent].blank? ? "Strata::ApplicationForm" : options[:parent]

        # Build arguments for the Rails model generator
        model_args = [ form_name ]

        # Merge base attributes with any additional arguments (attributes)
        # Base attributes take precedence over user-provided attributes
        attribute_args = merge_attributes_with_base_attributes(args)
        model_args.concat(attribute_args)
        model_args.concat([ "--parent", parent ])

        # Call the Rails model generator with transformed args
        generate("strata:model", *model_args)
      end

      private

      # Merges base attributes with user-provided attributes, ensuring base attributes take precedence
      def merge_attributes_with_base_attributes(user_attributes)
        base_attributes = Strata::ApplicationForm.base_attributes_for_generator
        return base_attributes.dup if user_attributes.empty?

        base_attribute_names = base_attributes.map { |attr| attr.split(":").first }

        filtered_user_attributes = user_attributes.reject do |user_attr|
          user_attr_name = user_attr.split(":").first
          base_attribute_names.include?(user_attr_name)
        end

        base_attributes.dup + filtered_user_attributes
      end
    end
  end
end
