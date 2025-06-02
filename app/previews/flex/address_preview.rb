module Flex
  # AddressPreview provides preview examples for the address component.
  # It demonstrates different states of the address input fields including empty,
  # filled, and invalid states.
  #
  # This class is used with Lookbook to generate UI component previews
  # for the address form component.
  #
  # @example Viewing the filled state preview
  #   # In Lookbook UI
  #   # Navigate to Flex > AddressPreview > filled
  #
  class AddressPreview < Lookbook::Preview
    layout "component_preview"

    def empty
      render template: "flex/previews/_address", locals: { model: new_model }
    end

    def filled
      model = new_model
      model.address = Flex::Address.new("123 Main St", "Apt 4B", "Anytown", "CA", "12345")
      render template: "flex/previews/_address", locals: { model: model }
    end

    def invalid
      model = new_model
      # Set invalid state by setting address fields but leaving required fields blank
      model.address_street_line_1 = "123 Main St"
      model.address_street_line_2 = "Apt 4B"
      model.address_city = "" # Invalid: required field is blank
      model.address_state = "" # Invalid: required field is blank
      model.address_zip_code = "invalid" # Invalid: doesn't match pattern
      model.valid?
      render template: "flex/previews/_address", locals: { model: model }
    end

    def custom_legend
      model = new_model
      render template: "flex/previews/_address", locals: { model: model, legend: "Custom Address Legend" }
    end

    private

    def new_model
      @model = Class.new do
        include ActiveModel::Model
        include ActiveModel::Attributes
        include ActiveModel::Validations
        include Flex::Attributes::AddressAttribute

        address_attribute :address

        validates :address_city, presence: true
        validates :address_state, presence: true
        validates :address_zip_code, format: { with: /\A[0-9]{5}(-[0-9]{4})?\z/, message: "must be a valid ZIP code" }, allow_blank: true

        def self.model_name
          ActiveModel::Name.new(self, nil, "TestModel")
        end
      end.new
    end
  end
end
