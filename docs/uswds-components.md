# USWDS Components

Strata ships a set of [ViewComponent](https://viewcomponent.org)-based wrappers around components from the [U.S. Web Design System](https://designsystem.digital.gov/components/). They render USWDS-compliant markup and class names, so you get accessible, on-brand UI without writing the boilerplate by hand.

All components live in the `Strata::US` namespace under [app/components/strata/us/](../app/components/strata/us/) and are rendered with the standard `render` helper:

```erb
<%= render Strata::US::AlertComponent.new(type: :info) do |alert| %>
  <% alert.with_body { "Hello" } %>
<% end %>
```

Every component accepts a `classes:` keyword for additional CSS classes and forwards any other keyword arguments as HTML attributes on the component's primary element (the `<table>` for [Table](#table); the wrapping element otherwise). Live previews are available in Lookbook (mounted at `/lookbook` in the dummy app — run `make start` and visit `http://localhost:3000/lookbook`); preview sources are under [app/previews/strata/us/](../app/previews/strata/us/).

## Components

1. [Accordion](#accordion)
2. [Alert](#alert)
3. [Breadcrumbs](#breadcrumbs)
4. [Button](#button)
5. [Card](#card)
6. [Card Group](#card-group)
7. [List](#list)
8. [Table](#table)

---

## Accordion

`Strata::US::AccordionComponent` — collapsible heading/body pairs. See [USWDS Accordion](https://designsystem.digital.gov/components/accordion/) and the [Lookbook preview](../app/previews/strata/us/accordion_component_preview.rb).

**Options**

- `heading_tag:` (required) — HTML tag used for each accordion heading (e.g. `:h2`, `:h3`).
- `id_prefix:` — prefix used to generate panel IDs. Defaults to a random `acrdn-XXXXXX-` value.
- `is_bordered:` — render the bordered variant. Defaults to `false`.
- `is_multiselectable:` — allow multiple panels open at once. Defaults to `false`.
- `classes:` — extra CSS classes appended to the root element.

**Slots**

- `with_heading` — heading content. Must be paired one-to-one with `with_body`.
- `with_body` — panel content (HTML allowed).

**Example**

```erb
<%= render Strata::US::AccordionComponent.new(heading_tag: :h3, is_bordered: true) do |accordion| %>
  <% accordion.with_heading { "First Amendment" } %>
  <% accordion.with_body { "<p>Congress shall make no law...</p>".html_safe } %>
  <% accordion.with_heading { "Second Amendment" } %>
  <% accordion.with_body { "<p>A well regulated Militia...</p>".html_safe } %>
<% end %>
```

---

## Alert

`Strata::US::AlertComponent` — site alerts in informational, warning, success, error, and emergency variants. See [USWDS Alert](https://designsystem.digital.gov/components/alert/) and the [Lookbook preview](../app/previews/strata/us/alert_component_preview.rb).

**Options**

- `type:` (required) — one of `:info`, `:warning`, `:success`, `:error`, `:emergency`.
- `slim:` — render the slim variant. Defaults to `false`.
- `with_icon:` — show the leading icon. Defaults to `true`.
- `heading_tag:` — HTML tag used for the heading. Defaults to `:h4`.
- `role:` — ARIA role for the wrapper (e.g. `"alert"`, `"status"`).
- `classes:` — extra CSS classes appended to the root element.

**Slots**

- `with_heading` — optional heading.
- `with_body` — alert body text.

**Example**

```erb
<%= render Strata::US::AlertComponent.new(type: :success) do |alert| %>
  <% alert.with_heading { "Saved" } %>
  <% alert.with_body { "Your changes have been saved." } %>
<% end %>

<%= render Strata::US::AlertComponent.new(type: :warning, slim: true, with_icon: false) do |alert| %>
  <% alert.with_body { "Heads up — read-only mode." } %>
<% end %>
```

---

## Breadcrumbs

`Strata::US::BreadcrumbsComponent` — a navigation trail of links ending in the current page. See [USWDS Breadcrumb](https://designsystem.digital.gov/components/breadcrumb/) and the [Lookbook preview](../app/previews/strata/us/breadcrumbs_component_preview.rb).

The last item is always rendered as the current page (no link, `usa-current` + `aria-current="page"`) regardless of whether an `href` was supplied.

**Options**

- `wrap:` — render the wrapping variant (crumbs wrap to multiple lines on narrow screens). Defaults to `false`.
- `aria_label:` — overrides the `aria-label` on the `<nav>`. Defaults to the i18n value at `strata.components.us.breadcrumbs.aria_label` (`"Breadcrumb"` in `en`, `"Ruta de navegación"` in `es-US`).
- `classes:` — extra CSS classes appended to the root `<nav>`.

Any other keyword arguments are forwarded as HTML attributes on the `<nav>`.

**Slots**

- `with_item(text = nil, href: nil, classes: nil, **html_attributes) { ... }` — a single crumb. Text may be passed as a positional or `text:` argument, or via a block. `href:` is optional; when omitted (or on the last crumb), the crumb renders without a link. Extra keyword arguments become HTML attributes on the `<li>`.
- `with_items(collection)` — render an item per element. Each element is a hash matching the keyword arguments to `with_item` (e.g. `{ text:, href: }`).

**Example**

```erb
<%= render Strata::US::BreadcrumbsComponent.new do |bc| %>
  <% bc.with_item(href: root_path) { "Home" } %>
  <% bc.with_item(href: cases_path) { "Cases" } %>
  <% bc.with_item { "Case #12345" } %>
<% end %>

<%= render Strata::US::BreadcrumbsComponent.new(wrap: true) do |bc| %>
  <% bc.with_items([
       { text: "Home", href: root_path },
       { text: "Cases", href: cases_path },
       { text: "Case #12345" }
     ]) %>
<% end %>
```

---

## Button

`Strata::US::ButtonComponent` — a USWDS-styled button rendered as either a `<button>` or an `<a>`. See [USWDS Button](https://designsystem.digital.gov/components/button/) and the [Lookbook preview](../app/previews/strata/us/button_component_preview.rb).

Pass an `href:` to render an `<a class="usa-button">`; otherwise the component renders a `<button>`.

**Options**

- `variant:` — visual variant. One of `:default` (primary), `:secondary`, `:accent_cool`, `:accent_warm`, `:base`, `:outline`, `:unstyled`. Defaults to `:default`.
- `size:` — `:default` or `:big`. Defaults to `:default`.
- `inverse:` — render the inverse modifier for use on dark backgrounds. Defaults to `false`. USWDS recommends pairing this with `:outline` or `:unstyled`.
- `type:` — `:button`, `:submit`, or `:reset`. Only applied to `<button>` elements (ignored when `href:` is set). Defaults to `:button`.
- `href:` — when set, renders an `<a>` element instead of a `<button>`.
- `disabled:` — when true, adds the `disabled` attribute on `<button>` or `aria-disabled="true"` on `<a>`. Defaults to `false`.
- `classes:` — extra CSS classes appended to the root element.

Any other keyword arguments are forwarded as HTML attributes on the rendered element.

**Example**

```erb
<%= render Strata::US::ButtonComponent.new do %>
  Save
<% end %>

<%= render Strata::US::ButtonComponent.new(href: edit_path, variant: :outline) do %>
  Edit
<% end %>

<%= render Strata::US::ButtonComponent.new(variant: :secondary, size: :big, disabled: true) do %>
  Delete
<% end %>
```

### Using the button style without the component

Some call sites need Rails to own the element rendering — most notably `button_to` (which generates its own `<form>`), `link_to`, `form.button`, and `f.submit`. For these, use the class-method helper `Strata::US::ButtonComponent.css_classes` to produce a matching USWDS class string:

```erb
<%= button_to "Delete", path, method: :delete,
      class: Strata::US::ButtonComponent.css_classes(variant: :secondary) %>

<%= link_to "Edit", edit_path,
      class: Strata::US::ButtonComponent.css_classes(variant: :outline) %>
```

The Strata form builder's `f.submit` already delegates to this helper internally and accepts the same `:variant` and `:big` options:

```erb
<%= f.submit "Save draft", variant: :outline %>
<%= f.submit "Apply", big: true %>
```

---

## Card

`Strata::US::CardComponent` — a container with optional header, media, body, and footer regions. See [USWDS Card](https://designsystem.digital.gov/components/card/) and the [Lookbook preview](../app/previews/strata/us/card_component_preview.rb).

At least one of header, media, body, or footer must be provided.

**Options**

- `tag:` — root tag. Defaults to `:div` (set to `:li` when nested inside a [Card Group](#card-group)).
- `heading_tag:` — HTML tag used for the card header. Defaults to `:h4`.
- `flag:` — render the flag layout (media beside content). Defaults to `false`.
- `flag_media_right:` — flag layout with media on the right. Implies `flag: true`.
- `header_first:` — show header above media in the flag layout. Requires `flag`.
- `media_inset:` — inset the media. Mutually exclusive with `media_exdent`.
- `media_exdent:` — extend the media to the card edges. Mutually exclusive with `media_inset`.
- `classes:` — extra CSS classes appended to the root element.

**Slots**

- `with_header`, `with_media`, `with_body`, `with_footer`.

**Example**

```erb
<%= render Strata::US::CardComponent.new do |card| %>
  <% card.with_header { "Card title" } %>
  <% card.with_media do %>
    <img src="/images/photo.jpg" alt="A description" />
  <% end %>
  <% card.with_body { "<p>Card body content.</p>".html_safe } %>
  <% card.with_footer do %>
    <%= button_tag "Action", class: "usa-button" %>
  <% end %>
<% end %>
```

---

## Card Group

`Strata::US::CardGroupComponent` — a `<ul>` wrapper that renders multiple cards as `<li>` items. See [USWDS Card group](https://designsystem.digital.gov/components/card/#card-group) and the [Lookbook preview](../app/previews/strata/us/card_group_component_preview.rb).

**Options**

- `classes:` — extra CSS classes appended to the root `<ul>`.

**Slots**

- `with_card(**options)` — yields a `CardComponent` (same options as above, except `tag` is fixed to `:li`).

**Example**

```erb
<%= render Strata::US::CardGroupComponent.new do |group| %>
  <% group.with_card do |card| %>
    <% card.with_header { "First card" } %>
    <% card.with_body { "Body" } %>
  <% end %>
  <% group.with_card(flag: true) do |card| %>
    <% card.with_header { "Second card" } %>
    <% card.with_body { "Body" } %>
  <% end %>
<% end %>
```

---

## List

`Strata::US::ListComponent` — a USWDS-styled `<ul>` or `<ol>`. See [USWDS Typography — lists](https://designsystem.digital.gov/components/typography/) and the [Lookbook preview](../app/previews/strata/us/list_component_preview.rb).

**Options**

- `ordered:` — render as an `<ol>` instead of `<ul>`. Defaults to `false`.
- `unstyled:` — remove markers and indentation. Defaults to `false`.
- `classes:` — extra CSS classes appended to the root list element.

**Slots**

- `with_item { ... }` — a single `<li>`.
- `with_items(collection)` — render an item per element.

**Example**

```erb
<%= render Strata::US::ListComponent.new do |list| %>
  <% list.with_item { "First" } %>
  <% list.with_item { "Second" } %>
<% end %>

<%= render Strata::US::ListComponent.new(ordered: true) do |list| %>
  <% list.with_items(["Apples", "Bananas", "Cherries"]) %>
<% end %>
```

---

## Table

`Strata::US::TableComponent` — semantic tables with USWDS style variants. See [USWDS Table](https://designsystem.digital.gov/components/table/) and the [Lookbook preview](../app/previews/strata/us/table_component_preview.rb).

**Options**

- `borderless:`, `striped:`, `compact:` — visual variants.
- `stacked:`, `stacked_header:` — responsive stacked layouts on narrow screens.
- `width_full:` — make the table fill its container.
- `scrollable:` — wrap the table in a horizontally scrollable container.
- `sticky_header:` — pin the header row when the table scrolls.
- `sortable:` — enable USWDS client-side sorting on `data-sortable` headers.
- `classes:` — extra CSS classes appended to the `<table>` element. Extra HTML attributes are also applied to the `<table>`, not the optional `scrollable` wrapper.

**Slots**

- `with_caption { ... }` — table caption.
- `with_header(scope:, sortable:, aria_sort:) { ... }` — one per column header.
- `with_row` — yields a row builder that exposes `with_cell(header:, scope:, label:, sort_value:) { ... }`.

The `label:` on a cell becomes the `data-label` used by the stacked variants. Use `header: true` on the first cell of a row when each row represents a labeled entity.

**Example**

```erb
<%= render Strata::US::TableComponent.new(striped: true, sortable: true) do |table| %>
  <% table.with_caption { "Planets by mass" } %>
  <% table.with_header(sortable: true) { "Name" } %>
  <% table.with_header(sortable: true, aria_sort: "ascending") { "Mass (10^24 kg)" } %>

  <% table.with_row do |row| %>
    <% row.with_cell(header: true, label: "Name") { "Earth" } %>
    <% row.with_cell(label: "Mass", sort_value: "5.97") { "5.97" } %>
  <% end %>
  <% table.with_row do |row| %>
    <% row.with_cell(header: true, label: "Name") { "Jupiter" } %>
    <% row.with_cell(label: "Mass", sort_value: "1898") { "1,898" } %>
  <% end %>
<% end %>
```
