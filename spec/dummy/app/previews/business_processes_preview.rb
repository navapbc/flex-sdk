# frozen_string_literal: true

class BusinessProcessesPreview < Lookbook::Preview
  def passport_business_process
    render template: "strata/previews/_business_process", locals: { business_process: PassportBusinessProcess }
  end

  def test_business_process
    render template: "strata/previews/_business_process", locals: { business_process: TestBusinessProcess }
  end
end
