# Strata Form Builder

The Strata Form builder is a custom form builder that provides USWDS-styled form components.

Beyond adding USWDS classes, this also supports:

- Setting labels and hints using the field helpers
- Automatically displaying inline error messages and styling
- Additional helpers for both basic elements, like fieldset and hint, and complex Strata elements, like names and addresses.

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

- [Email (email_field)](#email-field-email_field)
- [File (file_field)](#file-field-file_field)
- [Password (password_field)](#password-field-password_field)
- [Text Area (text_area)](#text-area-text_area)
- [Text (text_field)](#text-field-text_field)
- [Checkbox (check_box)](#checkbox-check_box)
- [Radio Button (radio_button)](#radio-button-radio_button)
- [Select (select)](#select-select)
- [Submit (submit)](#submit-submit)

### Basic Helpers

- [Fieldset (fieldset)](#fieldset-fieldset)
- [Form Group (form_group)](#form-group-form_group)
- [Hint (hint)](#hint-hint)
- [Conditional (conditional)](#conditional-conditional)
- [Honeypot (honeypot_field)](#honeypot-field-honeypot_field)

### Complex Helpers

- [Address (address_fields)](#address-fields-address_fields)
- [Date Picker (date_picker)](#date-picker-date_picker)
- [Date Range (date_range)](#date-range-date_range)
- [Memorable Date (memorable_date)](#memorable-date-memorable_date)
- [Money (money_field)](#money-field-money_field)
- [Name (name)](#name-name)
- [Tax ID (tax_id_field)](#tax-id-field-tax_id_field)
- [Yes/No (yes_no)](#yesno-yes_no)

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
- Accepts standard Rails [email_field](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-email_field) HTML options.

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
- Accepts standard Rails [file_field](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-file_field) HTML options.

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
- Accepts standard Rails [password_field](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-password_field) HTML options.

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
- Accepts standard Rails [text_area](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-text_area) HTML options.

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
- Accepts standard Rails [text_field](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-text_field) HTML options.

## Checkbox (check_box)

Renders a checkbox tag.

### Usage in form

```erb
<%= f.check_box :agree_to_terms, { label: "I agree to the terms" } %>
```

### Options

- `label`: Custom label text
- Accepts standard Rails [check_box](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-check_box) options (e.g. `checked_value`, `unchecked_value`) as well as any HTML options.

## Radio Button (radio_button)

Renders a radio button with USWDS styling, optionally as a tile.

### Usage in form

```erb
<%= f.fieldset "Choose one", { attribute: :favorite_fruit, hint: "Pick the best fruit" } do %>
  <%= f.radio_button :choice, "option_a", { label: "Option A" } %>
  <%= f.radio_button :choice, "option_b", { label: "Option B", tile: false } %>
%>
```

### Options

- `label`: Custom label text
- `tile`: When `true` (default), renders the radio as a USWDS tile; when `false`, renders as a standard radio control.
- Accepts standard Rails [radio_button](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-radio_button) HTML options.

## Select (select)

Renders a select input.

### Usage in form

```erb
<%= f.select :favorite_fruit, fruit_options, {
  label: "Favorite Fruit",
  hint: "Choose your favorite"
} %>
```

### Options

- `label`: Custom label text
- `hint`: Custom hint text
- `skip_form_group`: Renders the select without a wrapping form group
- Accepts standard Rails [select](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-select) options for choices and HTML attributes

## Submit (submit)

Renders a submit button.

### Usage in form

```erb
<%= f.submit "Save" %>
<%= f.submit "Continue", { big: true } %>
```

### Options

- `big`: When `true`, applies large USWDS button styling.
- Accepts standard Rails [submit](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-submit)/button HTML options.

## Fieldset (fieldset)

Renders a fieldset (`usa-fieldset`) with a required legend. Use it to group related inputs (e.g. radio buttons or custom composite fields).

### Usage in form

```erb
<%= f.fieldset "Choose one", { attribute: :favorite_fruit, hint: "Pick the best fruit" } do %>
  <%= f.radio_button :choice, "orange", { label: "Orange" } %>
  <%= f.radio_button :choice, "dragonfruit", { label: "Dragonfruit" } %>
<% end %>
```

### Options

- Legend text is the first argument (required).
- `attribute`: Attribute name
- `hint`: Hint text rendered below the legend.
- `large_legend`: When `true`, applies the large legend class (`usa-legend--large`).
- `group_options`: Options passed to the wrapping form group div.

## Form Group (form_group)

Wraps content in a USWDS form group div (`usa-form-group`).

### Usage in form

```erb
<%= f.form_group :email do %>
  <%= f.email_field :email, { label: "Email", skip_form_group: true } %>
<% end %>
```

### Options

- `attribute`: Attribute name
- `show_error`: When `true`, forces error styling to be rendered.

## Hint (hint)

Renders a block of hint text in a USWDS hint div (`usa-hint`).

### Usage in form

```erb
<%= f.hint "Enter your full legal name as it appears on your ID." %>
```

## Honeypot Field (honeypot_field)

Renders a hidden “honeypot” field intended to detect bots. The field is visually hidden and should be left empty by users; submissions that fill it can be treated as spam.

### Usage in form

```erb
<%= f.honeypot_field %>
```

## Conditional (conditional)

Conditionally shows or hides form fields based on a radio button's selected value. When the source radio button's value matches, the wrapped content is shown; otherwise it is hidden. Hidden inputs are automatically disabled so they are not submitted with the form.

### Usage in form

Show a text field when a yes/no radio is set to "yes":

```erb
<%= f.yes_no :has_employer, legend: "Do you currently have an employer?" %>

<%= f.conditional(:has_employer, eq: "true") do %>
  <%= f.text_field :employer_name, label: "Employer name" %>
<% end %>
```

Match against multiple radio options:

```erb
<%= f.fieldset "What type of leave are you requesting?", attribute: :leave_type do %>
  <%= f.radio_button :leave_type, "medical", label: "Medical" %>
  <%= f.radio_button :leave_type, "family", label: "Family" %>
  <%= f.radio_button :leave_type, "other", label: "Other" %>
<% end %>

<%= f.conditional(:leave_type, eq: "medical") do %>
  <%= f.text_field :medical_provider, label: "Medical provider" %>
<% end %>

<%= f.conditional(:leave_type, eq: "other") do %>
  <%= f.text_field :other_reason, label: "Please describe your reason for leave" %>
<% end %>
```

Match multiple values with an array:

```erb
<%= f.conditional(:leave_type, eq: ["medical", "family"]) do %>
  <%= f.text_field :provider_name, label: "Provider name" %>
<% end %>
```

### Options

- `eq`: **(required)** The value(s) to match against the source radio button. Accepts a single string or an array of strings. The conditional content is shown when the selected radio value matches any of the provided values.
- `clear`: When `true`, resets all inputs inside the conditional block (clears text values, unchecks radios/checkboxes) whenever the section is hidden. Defaults to `false`.

### Behavior

- **Initial state**: If the model already has a value that matches `eq`, the conditional content is shown on page load. Otherwise it starts hidden.
- **Disabled inputs**: When hidden, all inputs inside the conditional block are disabled so they are excluded from form submission.
- **Clearing values**: When `clear: true` is set, hiding the section also resets input values. This is useful when the conditional fields should not retain stale data after a user changes their selection.

## Address Fields (address_fields)

Renders a fieldset for Strata Address attribute fields.

### Usage in form

```erb
<%= f.address_fields :home_address %>
<%= f.address_fields :work_address, { legend: "Work address" } %>
```

### Options

- `legend`: Custom legend text for the fieldset
- Accepts `fieldset` options

## Date Picker (date_picker)

Renders a single date input with USWDS date picker styling.

### Usage in form

```erb
<%= f.date_picker :start_date, { label: "Start date" } %>
```

### Options

- Supports the same options as [text_field](#text-field-text_field) (e.g. `label`, `hint`, `label_class`, `group_options`, `skip_form_group`).

## Date Range (date_range)

Renders a fieldset for a Strata Range attribute.

### Usage in form

```erb
<%= f.date_range :employment_period %>
<%= f.date_range :leave_dates, { legend: "Cool Leave Dates" } %>
```

### Options

- `legend`: Custom legend text for the fieldset
- Accepts `fieldset` options

## Memorable Date (memorable_date)

Renders a fieldset for Strata Memorable Date attributes with month, day, and year inputs.

### Usage in form

```erb
<%= f.memorable_date :date_of_birth %>
```

### Options

- `legend`: Custom legend text
- `hint`: Custom hint text
- Accepts `fieldset` options

## Money Field (money_field)

Renders a text input for dollar amounts stored in a Strata Money attribute.

### Usage in form

```erb
<%= f.money_field :salary, { label: "Annual salary", hint: "Enter whole dollars" } %>
```

### Options

- `label`: Custom label text
- `hint`: Custom hint text
- `inputmode`: defaults to `"decimal"` if not set.
- `group_options`: Options passed to the wrapping form group
- Other options supported by [text_field](#text-field-text_field) (e.g. `class`, `placeholder`).

## Name (name)

Renders a fieldset for a Strata Name attribute.

### Usage in form

```erb
<%= f.name :applicant_name %>
```

### Options

- `legend`: Custom legend text
- `first_hint`: Hint for the first name field.
- `last_hint`: Hint for the last name field.

## Tax ID Field (tax_id_field)

Renders a masked text input suitable for SSN/TIN stored in a Strata Tax ID attribute.

### Usage in form

```erb
<%= f.tax_id_field :tax_identifier %>
```

### Options

- Same as [text_field](#text-field-text_field) (e.g. `label`, `hint`, `label_class`, `group_options`, `skip_form_group`)

## Yes/No (yes_no)

Renders a fieldset with two radio options for a boolean field.

### Usage in form

```erb
<%= f.yes_no :is_citizen, { legend: "Are you a U.S. citizen?" } %>
<%= f.yes_no :withhold_taxes, {
  legend: "Do you wish to withhold your taxes?",
  yes_options: { label: "Yes, withhold my taxes" },
  no_options: { label: "No, do not withhold my taxes" }
} %>
```

### Options

- `legend`: Legend text for the fieldset (defaults to the humanized attribute name).
- `yes_options`: Options passed to the “yes” radio (e.g. `label`)
- `no_options`: Options passed to the “no” radio (e.g. `label`)
- Accepts `fieldset` options
