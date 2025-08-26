module Flex
  module Attributes
    # DocumentAttribute provides a DSL for defining attributes representing
    # a collection of documents using ActiveStorage.
    #
    # @example Defining document attributes
    #   class Application < ApplicationRecord
    #     include Flex::Attributes
    #
    #     flex_attribute :identity_documents, :document
    #     flex_attribute :proof_of_income, :document
    #   end
    #
    #   application = Application.new
    #   application.identity_documents.attach(params[:identity_documents])
    #   application.proof_of_income.attach(params[:income_docs])
    #
    module DocumentAttribute
      extend ActiveSupport::Concern

      class_methods do
        # Defines a document attribute that uses ActiveStorage for file handling.
        #
        # @param [Symbol] name The base name for the attribute
        # @param [Hash] options Options for the attribute
        # @return [void]
        def document_attribute(name, options = {})
          # Set up ActiveStorage has_many_attached
          has_many_attached name

          # Define custom methods or validations here if needed in the future
        end
      end
    end
  end
end
