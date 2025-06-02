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

    def custom_legend
      model = new_model
      render template: "flex/previews/_address", locals: { model: model, legend: "Custom Address Legend" }
    end

    private

    def new_model
      TestRecord.new
    end
  end
end
