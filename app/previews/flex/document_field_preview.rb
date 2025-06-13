# Preview for the document field form component
class Flex::DocumentFieldPreview < Lookbook::Preview
  layout "component_preview"

  def empty
    render template: "flex/previews/document_field", locals: { model: TestRecord.new }
  end

  def with_hint
    render template: "flex/previews/document_field_with_hint", locals: { model: TestRecord.new }
  end

  def with_accept_filter
    render template: "flex/previews/document_field_with_accept", locals: { model: TestRecord.new }
  end
end
