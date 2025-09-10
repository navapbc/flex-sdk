module Flex
  module Cases
    class IndexPreview < Lookbook::Preview
      def empty
        render template: "flex/cases/index", locals: {
            model_class: PassportCase,
            cases: []
        }
      end

      def with_cases
        create_case = ->(attrs) {
          kase = PassportCase.new(
              id: attrs[:id],
              created_at: attrs[:created_at],
          )
          kase.send(:status=, attrs[:status])
          return kase
        }

        render template: "flex/cases/index", locals: {
            model_class: PassportCase,
            cases: [
              create_case.call({
                  id: "45c96903-b562-4817-ba80-d21a0cc276b9",
                  created_at: "2024-01-15",
                  status: :open
              }),
              create_case.call({
                  id: "28edb98c-3674-411e-8383-408eed8b427b",
                  created_at: "2024-01-10",
                  status: :closed
              })
            ]
        }
      end
    end
  end
end
