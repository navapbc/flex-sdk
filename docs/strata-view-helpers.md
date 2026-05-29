# Strata View Helpers

Strata ships a small set of Rails view helpers that wrap common Rails primitives and apply USWDS-aware styling. They're auto-included in any view rendered through Strata-using controllers (via `Strata::ApplicationHelper`), so you can use them without explicit `include` calls.

## Helpers

1. [`strata_link_to`](#strata_link_to) — Rails `link_to` with opt-in styling treatments
2. [`strata_button_to`](#strata_button_to) — Rails `button_to` with USWDS button styling

For the underlying ViewComponents, see [Strata::US::ButtonComponent](./uswds-components.md#button) and [Strata::US::LinkComponent](./uswds-components.md#link) in [uswds-components.md](./uswds-components.md).

---

## `strata_link_to`

Defined in [Strata::LinksHelper](../app/helpers/strata/links_helper.rb).

A wrapper around Rails' `link_to`. Without an `:as` keyword it's a pure passthrough — the helper exists as a single entry point for any Strata link styling. Pass `as: :button` to opt into USWDS button styling, or `as: :external` for the USWDS external-link treatment.

**Signature**

```ruby
strata_link_to(*args, as: nil, **html_options, &block)
```

`*args`, `**html_options`, and `&block` match Rails' `link_to`. The recognized treatments:

- `as: :button` — applies USWDS button styling. Accepts the additional keywords `:variant`, `:size`, and `:inverse` (same values as [`Strata::US::ButtonComponent`](./uswds-components.md#button)).
- `as: :external` — applies USWDS external-link styling (`usa-link usa-link--external`). Accepts `:alt` for the dark-background variant (`usa-link--alt`). The helper does not set `target` or `rel`; pass them explicitly if you want the link to open in a new tab.

A caller-supplied `:class` is appended to the treatment's classes.

**Errors**

- Raises `ArgumentError` if `:variant`, `:size`, or `:inverse` are passed without `as: :button` — catches the "forgot to opt in" mistake that would otherwise silently produce a plain link.
- Raises `ArgumentError` on an unrecognized `:as` value (currently `:button` and `:external` are supported).

**Examples**

```erb
<%# Plain link, no styling %>
<%= strata_link_to "Read more", article_path %>

<%# Button-styled link %>
<%= strata_link_to "Back", root_path, as: :button, variant: :outline %>

<%# Button-styled link with extra layout classes %>
<%= strata_link_to "Continue", next_path, as: :button, variant: :secondary, class: "margin-top-4" %>

<%# External link %>
<%= strata_link_to "USWDS docs", "https://designsystem.digital.gov/", as: :external %>

<%# External link that opens in a new tab — caller controls target/rel %>
<%= strata_link_to "USWDS docs", "https://designsystem.digital.gov/",
      as: :external, target: "_blank", rel: "noopener noreferrer" %>

<%# Block form %>
<%= strata_link_to article_path, as: :button do %>
  <svg aria-hidden="true">…</svg>
  Read more
<% end %>
```

---

## `strata_button_to`

Defined in [Strata::ButtonsHelper](../app/helpers/strata/buttons_helper.rb).

A wrapper around Rails' `button_to`. Rails' `button_to` always produces a `<form>` wrapping a `<button>` (with CSRF protection) — use it for non-GET actions like deletes, approvals, or any state-mutating click. `strata_button_to` always applies USWDS button styling; there's no passthrough mode because `button_to` is unambiguously about producing a button.

**Signature**

```ruby
strata_button_to(*args, variant: :default, size: :default, inverse: false, **html_options, &block)
```

`*args`, `**html_options`, and `&block` match Rails' `button_to`. `:variant`, `:size`, and `:inverse` map to the same values as [`Strata::US::ButtonComponent`](./uswds-components.md#button).

A caller-supplied `:class` is appended to the USWDS classes.

**Errors**

- Raises `ArgumentError` on an unrecognized variant/size — delegated to `Strata::US::ButtonComponent.css_classes`.

**Examples**

```erb
<%# Destructive POST/DELETE with CSRF %>
<%= strata_button_to "Delete", item_path(item), method: :delete, variant: :secondary %>

<%# Standard form-submit button with extra layout class %>
<%= strata_button_to "Apply", apply_path, method: :post, class: "margin-top-4" %>

<%# Big primary button, disabled when a condition isn't met %>
<%= strata_button_to "Review and submit", review_path, method: :get,
      size: :big, disabled: !@flow.completed? %>
```

---

## When neither helper fits

For call sites where Rails owns the element rendering but neither helper applies — `form.button` inside a `form_with`, a non-Strata `f.submit`, etc. — use the class-method helper directly:

```erb
<%= form.button "Approve", value: "approve",
      class: Strata::US::ButtonComponent.css_classes(variant: :secondary) %>
```

The Strata form builder's `f.submit` already delegates to this helper internally and accepts the same `:variant` and `:big` options without needing the explicit `class:`:

```erb
<%= f.submit "Save draft", variant: :outline %>
<%= f.submit "Apply", big: true %>
```

See [strata-form-builder.md](./strata-form-builder.md) for the full FormBuilder API.

---

## Using these helpers inside a ViewComponent

The "auto-included" note in the intro covers regular templates rendered by a controller (the helpers are mixed into `ActionView::Base` via `Strata::ApplicationHelper`). ViewComponents render in their own isolated context, so a bare `strata_button_to(...)` call inside a component template raises `NoMethodError: undefined method 'strata_button_to' for an instance of YourComponent`.

Two options:

1. **Call through the `helpers` proxy** — the convention used elsewhere in this codebase:

   ```erb
   <%# inside a component's .html.erb %>
   <%= helpers.strata_button_to "Continue", next_path, method: :get %>
   ```

   ```ruby
   # inside a component's .rb (e.g. a method that returns markup)
   helpers.strata_link_to(t(".actions.continue"), path, as: :button, method: :get)
   ```

2. **Include the helper module on the component class** — handy when a component calls a helper many times and the `helpers.` prefix becomes noisy:

   ```ruby
   class MyComponent < ViewComponent::Base
     include Strata::ButtonsHelper
     include Strata::LinksHelper
   end
   ```

In-tree examples of the `helpers.` proxy form: [task_list_component.html.erb](../app/components/strata/flows/task_list_component.html.erb) and [task_section_component.rb](../app/components/strata/flows/task_section_component.rb).
