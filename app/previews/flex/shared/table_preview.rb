module Flex
  module Shared
    class TablePreview < Lookbook::Preview
      def empty_no_headers
          render template: "flex/shared/_table", locals: { headers: [], rows: [] }
      end

      def empty_with_headers
          render template: "flex/shared/_table", locals: { headers: ["Col1", "Col2"], rows: [] }
      end

      def one_row
          render template: "flex/shared/_table", locals: { headers: ["Col1", "Col2"], rows: [["foo", "bar"]] }
      end

      def one_row_no_headers
          render template: "flex/shared/_table", locals: { headers: [], rows: [["foo", "bar"]] }
      end

      def multiple_row
          render template: "flex/shared/_table", locals: { headers: ["Col1", "Col2"], rows: [["foo", "bar"], ["bar", "baz"], ["quux", "fui"]] }
      end
    end
  end
end
