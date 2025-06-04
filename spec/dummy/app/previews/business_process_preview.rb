class BusinessProcessPreview < Lookbook::Preview
  layout "mermaid_diagram"

  def passport_business_process
    render template: "flex/previews/_business_process", locals: { business_process: PassportBusinessProcess }
  end

  def test_business_process
    render template: "flex/previews/_business_process", locals: { business_process: TestBusinessProcess }
  end
end
