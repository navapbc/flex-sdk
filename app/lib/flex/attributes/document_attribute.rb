module Flex
  module Attributes
    # DocumentAttribute provides a DSL for defining document attributes in form models.
    # It creates file attachment fields that integrate with ActiveStorage's has_many_attached
    # functionality while providing a clean interface through the DocumentCollection value object.
    #
    # This module includes a custom ActiveRecord type that handles file uploads
    # and integrates with the Flex::DocumentCollection value object.
    #
    # @example Adding a document attribute to a form model
    #   class MyForm < Flex::ApplicationForm
    #     include Flex::Attributes::DocumentAttribute
    #     document_attribute :supporting_documents
    #   end
    #
    # Key features:
    # - Integration with ActiveStorage for file handling
    # - Support for multiple file uploads
    # - Validation support for file types and sizes
    # - Clean interface through DocumentCollection value object
    #
    module DocumentAttribute
      extend ActiveSupport::Concern

      # A custom ActiveRecord type that handles document attachments.
      # It integrates with ActiveStorage and provides casting between
      # form inputs and the DocumentCollection value object.
      class DocumentType < ActiveModel::Type::Value
        def cast(value)
          return nil if value.nil?
          return value if value.is_a?(Flex::DocumentCollection)

          case value
          when ActionDispatch::Http::UploadedFile, Array
            # Handle file uploads from forms - these will be processed by ActiveStorage
            # We return nil here because ActiveStorage handles the actual attachment
            nil
          when ActiveStorage::Attached::Many
            # Wrap existing ActiveStorage attachments in our value object
            Flex::DocumentCollection.new(value)
          else
            nil
          end
        end

        def serialize(value)
          # ActiveStorage handles serialization, so we don't need to do anything
          nil
        end

        def deserialize(value)
          # ActiveStorage handles deserialization, so we don't need to do anything
          nil
        end

        def type
          :document
        end
      end

      class_methods do
        def document_attribute(name, options = {})
          # Set up ActiveStorage attachment
          has_many_attached :"#{name}_files"

          # Define the attribute with our custom type
          attribute name, DocumentType.new

          # Define the getter method that returns a DocumentCollection
          define_method(name) do
            attachments = send(:"#{name}_files")
            Flex::DocumentCollection.new(attachments)
          end

          # Define the setter method that handles file uploads
          define_method("#{name}=") do |value|
            case value
            when ActionDispatch::Http::UploadedFile, Rack::Test::UploadedFile
              send(:"#{name}_files").attach(value)
            when Array
              # Handle multiple file uploads
              value.compact.each do |file|
                send(:"#{name}_files").attach(file) if file.present?
              end
            when Flex::DocumentCollection
              # Already handled by ActiveStorage
            end
          end
        end
      end
    end
  end
end
