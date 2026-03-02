# frozen_string_literal: true

module Strata
  module US
    # TableComponentPreview provides preview examples for the Strata::US::TableComponent.
    class TableComponentPreview < Lookbook::Preview
      layout "strata/component_preview"

      # @label Basic Table
      def default
        render Strata::US::TableComponent.new do |table|
          table.with_caption { "Alphabetical list of planets in our solar system" }
          table.with_header { "Name" }
          table.with_header { "Mass (10^24 kg)" }
          table.with_header { "Diameter (km)" }

          table.with_row do |row|
            row.with_cell { "Earth" }
            row.with_cell { "5.97" }
            row.with_cell { "12,756" }
          end
          table.with_row do |row|
            row.with_cell { "Jupiter" }
            row.with_cell { "1,898" }
            row.with_cell { "142,984" }
          end
          table.with_row do |row|
            row.with_cell { "Mars" }
            row.with_cell { "0.642" }
            row.with_cell { "6,792" }
          end
        end
      end

      # @label Striped Table
      def striped
        render Strata::US::TableComponent.new(striped: true) do |table|
          table.with_header { "Document name" }
          table.with_header { "Status" }
          table.with_header { "Date modified" }

          table.with_row do |row|
            row.with_cell { "Declaration of Independence" }
            row.with_cell { "Signed" }
            row.with_cell { "July 4, 1776" }
          end
          table.with_row do |row|
            row.with_cell { "Bill of Rights" }
            row.with_cell { "Ratified" }
            row.with_cell { "December 15, 1791" }
          end
          table.with_row do |row|
            row.with_cell { "Constitution" }
            row.with_cell { "Ratified" }
            row.with_cell { "June 21, 1788" }
          end
        end
      end

      # @label Borderless Table
      def borderless
        render Strata::US::TableComponent.new(borderless: true) do |table|
          table.with_header { "User" }
          table.with_header { "Role" }
          table.with_header { "Last Login" }

          table.with_row do |row|
            row.with_cell { "John Doe" }
            row.with_cell { "Admin" }
            row.with_cell { "2 minutes ago" }
          end
          table.with_row do |row|
            row.with_cell { "Jane Smith" }
            row.with_cell { "Editor" }
            row.with_cell { "1 hour ago" }
          end
        end
      end

      # @label Compact Table
      def compact
        render Strata::US::TableComponent.new(compact: true) do |table|
          table.with_header { "Metric" }
          table.with_header { "Value" }

          table.with_row do |row|
            row.with_cell { "CPU Usage" }
            row.with_cell { "12%" }
          end
          table.with_row do |row|
            row.with_cell { "Memory" }
            row.with_cell { "45%" }
          end
        end
      end

      # @label Stacked Table
      def stacked
        render Strata::US::TableComponent.new(stacked: true) do |table|
          table.with_caption { "Stacked table: headers are hidden and row data is displayed with labels in a single column on small screens." }
          table.with_header { "Document name" }
          table.with_header { "Status" }
          table.with_header { "Date modified" }

          table.with_row do |row|
            row.with_cell(label: "Document name") { "Declaration of Independence" }
            row.with_cell(label: "Status") { "Signed" }
            row.with_cell(label: "Date modified") { "July 4, 1776" }
          end
          table.with_row do |row|
            row.with_cell(label: "Document name") { "Bill of Rights" }
            row.with_cell(label: "Status") { "Ratified" }
            row.with_cell(label: "Date modified") { "December 15, 1791" }
          end
        end
      end

      # @label Stacked Header Table
      def stacked_header
        render Strata::US::TableComponent.new(stacked_header: true) do |table|
          table.with_caption { "Stacked header table: headers remain visible and row data is grouped under them on small screens." }
          table.with_header { "Document name" }
          table.with_header { "Status" }
          table.with_header { "Date modified" }

          table.with_row do |row|
            row.with_cell { "Declaration of Independence" }
            row.with_cell { "Signed" }
            row.with_cell { "July 4, 1776" }
          end
          table.with_row do |row|
            row.with_cell { "Bill of Rights" }
            row.with_cell { "Ratified" }
            row.with_cell { "December 15, 1791" }
          end
        end
      end

      # @label Sortable Table
      def sortable
        render Strata::US::TableComponent.new(sortable: true, scrollable: true) do |table|
          table.with_caption { "List of planets in our solar system" }
          table.with_header(sortable: true, aria_sort: "ascending") { "Name" }
          table.with_header(sortable: true) { "Mass (10^24 kg)" }
          table.with_header(sortable: true) { "Date" }
          table.with_header(sortable: false) { "Non-sortable" }

          table.with_row do |row|
            row.with_cell { "Earth" }
            row.with_cell(sort_value: "5.97") { "5.97" }
            row.with_cell(sort_value: "-6106032422") { "July 4, 1776" }
            row.with_cell { "..." }
          end
          table.with_row do |row|
            row.with_cell { "Jupiter" }
            row.with_cell(sort_value: "1898") { "1,898" }
            row.with_cell(sort_value: "-5618563622") { "December 15, 1791" }
            row.with_cell { "..." }
          end
        end
      end

      # @label Row Headers
      def row_headers
        render Strata::US::TableComponent.new do |table|
          table.with_header { "Candidate" }
          table.with_header { "Party" }
          table.with_header { "Votes" }

          table.with_row do |row|
            row.with_cell(header: true) { "George Washington" }
            row.with_cell { "Independent" }
            row.with_cell { "69" }
          end
          table.with_row do |row|
            row.with_cell(header: true) { "John Adams" }
            row.with_cell { "Federalist" }
            row.with_cell { "34" }
          end
        end
      end

      # @label Scrollable Sticky Header
      def scrollable_sticky
        render Strata::US::TableComponent.new(sticky_header: true) do |table|
          table.with_caption { "Sticker header table" }
          table.with_header { "Fixed Header 1" }
          table.with_header { "Fixed Header 2" }
          table.with_header { "Fixed Header 3" }

          (1..10).each do |i|
            table.with_row do |row|
              row.with_cell { "Data #{i}-1" }
              row.with_cell { "Data #{i}-2" }
              row.with_cell { "Data #{i}-3" }
            end
          end
        end
      end
    end
  end
end
