module Flex
  module ApplicationHelper
    def flex_form_with(model: nil, scope: nil, url: nil, format: nil, **options, &block)
      options[:builder] = Flex::FormBuilder
      form_with model: model, scope: scope, url: url, format: format, **options, &block
    end
  end
end
