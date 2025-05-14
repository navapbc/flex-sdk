module Flex
  module Cases
    class IndexPreview < Lookbook::Preview
      def default
        render template: "flex/cases/index", locals: {
          action_name: "index",
          cases_path: "/cases",
          closed_cases_path: "/cases/closed",
          cases: [
            { id: 1, created_at: "3/14/2025" },
            { id: 2, created_at: "3/15/2025" },
          ],
          title: "Cases",
        }
      end

      def empty
        render template: "flex/cases/index", locals: {
          action_name: "index",
          cases_path: "/cases",
          closed_cases_path: "/cases/closed",
          cases: [],
          title: "Cases",
        }
      end

      def closed
        render template: "flex/cases/index", locals: {
          action_name: "closed",
          cases_path: "/cases",
          closed_cases_path: "/cases/closed",
          cases: [
            { id: 1, created_at: "3/14/2025" },
            { id: 2, created_at: "3/15/2025" },
          ],
          title: "Cases",
        }
      end
    end
  end
end
