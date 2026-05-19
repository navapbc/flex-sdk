# USWDS Components

Strata ships a set of [ViewComponent](https://viewcomponent.org)-based wrappers around components from the [U.S. Web Design System](https://designsystem.digital.gov/components/). They render USWDS-compliant markup and class names, so you get accessible, on-brand UI without writing the boilerplate by hand.

All components live in the `Strata::US` namespace under [app/components/strata/us/](../app/components/strata/us/) and are rendered with the standard `render` helper:

```erb
<%= render Strata::US::AlertComponent.new(type: :info) do |alert| %>
  <% alert.with_body { "Hello" } %>
<% end %>
```

Most components accept a `classes:` keyword for additional CSS classes and forward any other keyword arguments as HTML attributes on the component's primary element — see each component's options below for specifics. Live previews are available in Lookbook (mounted at `/lookbook` in the dummy app — run `make start` and visit `http://localhost:3000/lookbook`); preview sources are under [app/previews/strata/us/](../app/previews/strata/us/).

## Components

1. [Accordion](#accordion)
2. [Alert](#alert)
3. [Card](#card)
4. [Card Group](#card-group)
5. [List](#list)
6. [Table](#table)

---

## Accordion

`Strata::US::AccordionComponent` — collapsible heading/body pairs. See [USWDS Accordion](https://designsystem.digital.gov/components/accordion/) and the [Lookbook preview](../app/previews/strata/us/accordion_component_preview.rb).

**Options**

- `heading_tag:` (required) — HTML tag used for each accordion heading (e.g. `:h2`, `:h3`).
- `id_prefix:` — prefix used to generate panel IDs. Defaults to a random `acrdn-XXXXXX-` value.
- `is_bordered:` — render the bordered variant. Defaults to `false`.
- `is_multiselectable:` — allow multiple panels open at once. Defaults to `false`.

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
