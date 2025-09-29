# Contributing new FormBuilder helper methods

This document describes how to create a new FormBuilder helper method for rendering form fields associated with a Strata attribute.

## Design

1. Look at the associated value object type for the Strata attribute to determine what form fields are appropriate for the attribute.
   Subclasses of `String` should use `text_field`.
   Value objects that are `composed_of` other value objects should contain multiple fields. Recursively look at the value object type of the nested value objects to determine what form fields are appropriate for those attributes.

## Implementation

1. Render the entire attribute in a `fieldset`.
2. In general use existing helper methods in the FormBuilder (e.g. `text_field`, `yes_no`, `check_box`, `radio_button`, `select`) rather than helper methods directly on `@template`. These helper methods already render `field_error` and `label` for the field, so you don't need to do that yourself.
3. For value types that are `composed_of` nested value types (i.e. ones that are implemented using `composed_of`):
   1. Do not use `fields_for` block to group the nested fields. Create fields for the nested value objects directly in the `fieldset`.
   2. If there are no validations on the Strata attribute, do not render a top level `field_error` for the `fieldset`.
4. Add relevant I18n strings to config/locales/strata/en.yml and config/locales/strata/es-US.yml under the scope `<local>.strata.form_builder.<strata_attribute_type>`.
5. Add tests to form_builder_spec.rb for the new helper method. The tests should cover:
   1. Rendering the field with a valid value.
   2. Rendering the field with an invalid value (if applicable).
   3. Rendering the field with no value.
   4. Rendering the field with a value that has been set in the Strata attribute.
   5. Rendering the field with a value that has been set in the Strata attribute and is invalid (if applicable).
6. Add LookBook previews for the new helper method in `app/previews/strata/`. You'll need to add an associated partial view in `app/views/strata/previews/` which renders the form field using the new helper method.
   1. Create a new partial template in `views/strata/previews/`. The partial template should use the Strata Form Builder and set url to false to avoid issues with path helpers. So it should look like:

      ```erb
      <%= strata_form_with(model: model, url: false) do |f| %>
         <%= f.new_form_helper_method :name_of_attribute_on_test_record %>
      <% end %>
      ```

   2. The preview class should subclass `Lookbook::Preview` not `ViewComponent::Preview`. Each preview method should call `render` not `render_with_template`. The preview method should look like this:

      ```ruby
      class Strata::Previews::NewFormHelperMethodPreview < Lookbook::Preview
        def empty
          render template: "strata/previews/new_form_helper_method", locals: { model: TestRecord.new }
        end

        def filled
          ...
        end

        # Only include invalid preview if the Strata attribute has validations.
        def invalid
          ...
        end
      end
      ```

Test the previews by navigating to `/lookbook`
