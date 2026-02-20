# Strata Form Builder

The Strata Form builder is a custom form builder that provides USWDS-styled form components.

Beyond adding USWDS classes, this also supports setting labels and hints using the field helpers; automatically displays inline error messages and styling, and adds additional helpers for both basic elements, like fieldset and hint, and complex Strata elements, like names and addresses.

## Basic usage

```erb
<%= strata_form_with(model: @leave_application, url: update_personal_info_path(@leave_application), method: :patch) do |f| %>
  <%= f.name :applicant_name, {
    legend: t(".applicant_name_title"),
    hint: t(".applicant_name_hint"),
    large_legend: true
  } %>
  <%= f.submit "Save" %>
<% end %>
```

## Table of Contents

### Standard Rails Helpers

These helper methods override standard Rails form helpers to use accessible USWDS markup with labels, hints, and conditional error styling.

- [email_field](#email-field)
- [file_field](#file-field)
- [password_field](#password-field)
- [text_area]
- [text_field]
- [check_box]
- [radio_button]
- [submit]

- [fieldset]
- [form_group]
- [hint]
- [honeypot_field]
- [select]

### Custom Attribute Helpers

- [address_fields]
- [date_picker]
- [date_range]
- [memorable_date]
- [money_field]
- [name]
- [tax_id_field]
- [yes_no]

## Email Field (email_field)

Returns a text_field of type “email”.

### Usage in form

```erb
<%= f.email_field :email_address, {
  label: "Custom label text",
  hint: "Some hint text"
} %>
```

### Options

- `label`: Custom label text
- `hint`: Custom hint text
- `label_class`: Custom class for the label tag
- `group_options`: Options to pass into the wrapping form_group
- `skip_form_group`: Renders tag without a wrapping form_group

## File Field (file_field)

Returns a file upload input tag.

## Password Field (password_field)

## Text Area (text_area)

## Text Field (text_field)

## Checkbox (check_box)

Renders a checkbox field.

## Radio Button (radio_button)

## Submit (submit)

## Fieldset (fieldset)

## Form Group (form_group)

## Hint (hint)

## Honeypot Field (honeypot_field)

## Select (select)

## Address Fields (address_fields)

## Date Picker (date_picker)

## Date Range (date_range)

## Memorable Date (memorable_date)

## Money Field (money_field)

## Name (name)

## Tax ID Field (tax_id_field)

## Yes/No (yes_no)
