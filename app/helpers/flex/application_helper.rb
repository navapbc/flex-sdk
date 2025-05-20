module Flex
  # ApplicationHelper provides view helpers for common tasks in Flex applications.
  # It includes methods for working with forms, UI components, and more.
  #
  # @example Creating a Flex form with USWDS styling
  #   <%= flex_form_with(model: @application_form) do |f| %>
  #     <%= f.text_field :name %>
  #   <% end %>
  #
  module ApplicationHelper
    def flex_form_with(model: nil, scope: nil, url: nil, format: nil, **options, &block)
      options[:builder] = Flex::FormBuilder
      form_with model: model, scope: scope, url: url, format: format, **options, &block
    end
  end
end
