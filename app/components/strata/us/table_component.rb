# frozen_string_literal: true

module Strata
  module US
    # TableComponent renders a USWDS table with various style variants.
    #
    # @example Basic usage
    #   <%= render Strata::US::TableComponent.new do |table| %>
    #     <% table.with_caption { "Alphabetical list of planets" } %>
    #     <% table.with_header { "Name" } %>
    #     <% table.with_header { "Mass (10^24 kg)" } %>
    #
    #     <% table.with_row do |row| %>
    #       <% row.with_cell { "Earth" } %>
    #       <% row.with_cell { "5.97" } %>
    #     <% end %>
    #     <% table.with_row do |row| %>
    #       <% row.with_cell { "Jupiter" } %>
    #       <% row.with_cell { "1,898" } %>
    #     <% end %>
    #   <% end %>
    class TableComponent < ViewComponent::Base
      renders_one :caption
      renders_many :headers, "Strata::US::TableComponent::HeaderComponent"
      renders_many :rows, "Strata::US::TableComponent::RowComponent"

      def initialize(
        borderless: false,
        striped: false,
        compact: false,
        stacked: false,
        stacked_header: false,
        width_full: false,
        scrollable: false,
        sticky_header: false,
        sortable: false,
        classes: nil,
        **html_attributes
      )
        @borderless = borderless
        @striped = striped
        @compact = compact
        @stacked = stacked
        @stacked_header = stacked_header
        @width_full = width_full
        @scrollable = scrollable
        @sticky_header = sticky_header
        @sortable = sortable
        @classes = classes
        @html_attributes = html_attributes
      end

      def table_classes
        class_names(
          "usa-table",
          {
            "usa-table--borderless" => @borderless,
            "usa-table--striped" => @striped,
            "usa-table--compact" => @compact,
            "usa-table--stacked" => @stacked,
            "usa-table--stacked-header" => @stacked_header,
            "usa-table--width-full" => @width_full,
            "usa-table--sticky-header" => @sticky_header
          },
          @classes
        )
      end

      # Renders a table header cell (<th>) within the table's <thead>.
      class HeaderComponent < ViewComponent::Base
        attr_reader :attributes

        def initialize(scope: "col", sortable: nil, aria_sort: nil, classes: nil, **html_attributes)
          @sortable = sortable
          aria_sort = aria_sort || (@sortable ? "none" : nil)
          @attributes = html_attributes.merge(
            role: "columnheader",
            scope: scope,
            class: classes
          )
          @attributes[:"aria-sort"] = aria_sort if aria_sort
        end

        def call
          content
        end

        def sortable?
          @sortable
        end
      end

      # Renders a table row (<tr>) containing one or more CellComponents.
      class RowComponent < ViewComponent::Base
        renders_many :cells, "Strata::US::TableComponent::CellComponent"

        def initialize(classes: nil, **html_attributes)
          @classes = classes
          @html_attributes = html_attributes
        end

        def call
          content_tag :tr, class: @classes, **@html_attributes do
            if cells.any?
              cells.each { |cell| concat(cell) }
            else
              concat(content)
            end
          end
        end
      end

      # Renders a table cell (<td>) or row header (<th>) within a RowComponent.
      class CellComponent < ViewComponent::Base
        def initialize(header: false, scope: nil, label: nil, sort_value: nil, classes: nil, **html_attributes)
          @header = header
          @scope = scope || (@header ? "row" : nil)
          @label = label
          @sort_value = sort_value
          @classes = classes
          @html_attributes = html_attributes
        end

        def call
          tag_name = @header ? :th : :td
          attrs = @html_attributes.deep_dup
          attrs[:role] = "rowheader" if @header
          attrs[:data] ||= {}
          attrs[:data][:label] = @label if @label
          attrs[:data][:sort_value] = @sort_value if @sort_value
          content_tag tag_name, content, scope: @scope, class: @classes, **attrs
        end
      end
    end
  end
end
