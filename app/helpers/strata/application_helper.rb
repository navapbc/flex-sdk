# frozen_string_literal: true

module Strata
  # ApplicationHelper provides view helpers for common tasks in Strata applications.
  # It includes the strata_form_with method.
  #
  # @see Strata::FormBuilder for more information about available form helpers
  #
  module ApplicationHelper
    def strata_form_with(model: false, scope: nil, url: nil, format: nil, **options, &block)
      options[:builder] = Strata::FormBuilder
      args = { scope: scope, url: url, format: format, **options }
      args[:model] = model if model
      form_with(**args, &block)
    end
  end
end
