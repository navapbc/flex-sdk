# frozen_string_literal: true

require "rails_helper"

RSpec.describe Strata::US::TableComponent, type: :component do
  it "renders a basic table" do
    render_inline(described_class.new) do |table|
      table.with_header { "Column 1" }
      table.with_header { "Column 2" }
      table.with_row do |row|
        row.with_cell { "Data 1" }
        row.with_cell { "Data 2" }
      end
    end

    expect(page).to have_css("table.usa-table")
    expect(page).to have_css("thead th[role='columnheader']", text: "Column 1")
    expect(page).to have_css("thead th[role='columnheader']", text: "Column 2")
    expect(page).to have_css("tbody tr td", text: "Data 1")
    expect(page).to have_css("tbody tr td", text: "Data 2")
  end

  it "renders a caption" do
    render_inline(described_class.new) do |table|
      table.with_caption { "My Table Caption" }
    end

    expect(page).to have_css("caption", text: "My Table Caption")
  end

  it "applies variant classes" do
    render_inline(described_class.new(
      borderless: true,
      striped: true,
      compact: true,
      stacked: true,
      stacked_header: true,
      width_full: true,
      sticky_header: true
    ))

    expect(page).to have_css(".usa-table--borderless")
    expect(page).to have_css(".usa-table--striped")
    expect(page).to have_css(".usa-table--compact")
    expect(page).to have_css(".usa-table--stacked")
    expect(page).to have_css(".usa-table--stacked-header")
    expect(page).to have_css(".usa-table--width-full")
    expect(page).to have_css(".usa-table--sticky-header")
  end

  it "renders a sortable table" do
    render_inline(described_class.new(sortable: true)) do |table|
      table.with_header(sortable: true, aria_sort: "ascending") { "Name" }
      table.with_header(sortable: false) { "Non-sortable" }
      table.with_row do |row|
        row.with_cell(sort_value: "123") { "Formatted Value" }
      end
    end

    expect(page).to have_css("table[data-sortable]")
    expect(page).to have_css("th[data-sortable][aria-sort='ascending']", text: "Name")
    expect(page).not_to have_css("th[data-sortable]", text: "Non-sortable")
    expect(page).to have_css("td[data-sort-value='123']", text: "Formatted Value")
  end

  it "wraps in a scrollable container when scrollable is true" do
    render_inline(described_class.new(scrollable: true))

    expect(page).to have_css(".usa-table-container--scrollable")
    expect(page).to have_css(".usa-table-container--scrollable table")
  end

  it "supports row headers" do
    render_inline(described_class.new) do |table|
      table.with_header { "Header" }
      table.with_row do |row|
        row.with_cell(header: true) { "Row Header" }
        row.with_cell { "Value" }
      end
    end

    expect(page).to have_css("tbody th[scope='row'][role='rowheader']", text: "Row Header")
    expect(page).to have_css("tbody td", text: "Value")
  end

  it "passes html attributes to the table" do
    render_inline(described_class.new(id: "my-table", data: { test: "value" }))

    expect(page).to have_css("table#my-table[data-test='value']")
  end

  it "passes html attributes to headers, rows, and cells" do
    render_inline(described_class.new) do |table|
      table.with_header(id: "h1", classes: "custom-h") { "H1" }
      table.with_row(id: "r1", classes: "custom-r") do |row|
        row.with_cell(id: "c1", classes: "custom-c") { "C1" }
      end
    end

    expect(page).to have_css("th#h1.custom-h")
    expect(page).to have_css("tr#r1.custom-r")
    expect(page).to have_css("td#c1.custom-c")
  end
end
