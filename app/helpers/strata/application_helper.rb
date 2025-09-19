module Strata
  # ApplicationHelper provides view helpers for common tasks in Strata applications.
  # It includes the strata_form_with method.
  #
  # @see Strata::FormBuilder for more information about available form helpers
  #
  module ApplicationHelper
    def strata_form_with(model: nil, scope: nil, url: nil, format: nil, **options, &block)
      options[:builder] = Strata::FormBuilder
      form_with model: model, scope: scope, url: url, format: format, **options, &block
    end
  end
end
