# Contributing new FormBuilder helper methods

This document describes how to create a new FormBuilder helper method for rendering form fields associated with a Flex attribute.

## Design

1. Look at the associated value object type for the Flex attribute to determine what form fields are appropriate for the attribute.
   Subclasses of `String` should use `text_field`.
   Value objects that are `composed_of` other value objects should contain multiple fields. Recursively look at the value object type of the nested value objects to determine what form fields are appropriate for those attributes.

## Implementation

1. Render the entire attribute in a `fieldset`.
2. In general use existing helper methods in the FormBuilder (e.g. `text_field`, `yes_no`, `check_box`, `radio_button`, `select`) rather than helper methods directly on `@template`. These helper methods already render `field_error` and `label` for the field, so you don't need to do that yourself.
3. For value types that are `composed_of` nested value types (i.e. ones that are implemented using `composed_of`):
   1. Do not use `fields_for` block to group the nested fields. Create fields for the nested value objects directly in the `fieldset`.
   2. If there are no validations on the Flex attribute, do not render a top level `field_error` for the `fieldset`.
4. Add LookBook previews for the new helper method in `app/previews/flex/`. You'll need to add an associated partial view in `app/views/flex/previews/` which renders the form field using the new helper method.
