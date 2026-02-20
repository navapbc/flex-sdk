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
- [text_area](#text-area)
- [text_field](#text-field)
- [check_box](#checkbox-check_box)
- [radio_button](#radio-button-radio_button)
- [submit](#submit-submit)

## Nonstandard Rails Helpers

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
- Accepts standard Rails `email_field` HTML options.

## File Field (file_field)

Returns a file upload input tag.

### Usage in form

```erb
<%= f.file_field :attachment, {
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
- Accepts standard Rails `file_field` HTML options.

## Password Field (password_field)

Returns a text field of type "password".

### Usage in form

```erb
<%= f.password_field :password, {
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
- Accepts standard Rails `password_field` HTML options.

## Text Area (text_area)

Returns a multi-line text input.

### Usage in form

```erb
<%= f.text_area :description, {
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
- Accepts standard Rails `text_area` HTML options.

## Text Field (text_field)

Returns a single-line text input.

### Usage in form

```erb
<%= f.text_field :name, {
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
- Accepts standard Rails `text_field` HTML options.

## Checkbox (check_box)

Renders a checkbox tag.

### Usage in form

```erb
<%= f.check_box :agree_to_terms, { label: "I agree to the terms" } %>
```

### Options

- `label`: Custom label text
- Accepts standard Rails `check_box` options (e.g. `checked_value`, `unchecked_value`) as well as any HTML options.

## Radio Button (radio_button)

Renders a radio button with USWDS styling, optionally as a tile.

### Usage in form

```erb
<%= f.radio_button :choice, "option_a", { label: "Option A" } %>
<%= f.radio_button :choice, "option_b", { label: "Option B", tile: false } %>
```

### Options

- `label`: Custom label text
- `tile`: When `true` (default), renders the radio as a USWDS tile; when `false`, renders as a standard radio control.
- Accepts standard Rails `radio_button` HTML options.

## Submit (submit)

Renders a submit button with USWDS button styling.

### Usage in form

```erb
<%= f.submit "Save" %>
<%= f.submit "Continue", { big: true } %>
```

### Options

- `big`: When `true`, applies large button styling (`usa-button--big margin-y-6`).
- Accepts standard Rails `submit`/button HTML options.

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
