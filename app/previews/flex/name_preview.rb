module Flex
  # Lookbook preview for FormBuilder#name helper method.
  class NamePreview < Lookbook::Preview
    layout "component_preview"

    def empty
      render template: "flex/previews/_name", locals: { model: new_model }
    end

    def filled
      model = new_model
      model.name = Name.new("John", "Quincy", "Doe")
      render template: "flex/previews/_name", locals: { model: model }
    end

    private

    def new_model
      TestRecord.new
    end
  end
end
