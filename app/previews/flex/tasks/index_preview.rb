module Flex
  module Tasks
    class IndexPreview < Lookbook::Preview
      def empty
        render template: "flex/tasks/index", locals: {
          model_class: Flex::Task,
          title: "My Tasks",
          distinct_task_types: [
            "VerifyInformation",
            "VerifyPhoto"
          ],
          tasks: []
        }
      end

      def with_applications
        render template: "flex/tasks/index", locals: {
          model_class: Flex::Task,
          title: "My Tasks",
          distinct_task_types: [
            "VerifyInformation",
            "VerifyPhoto"
          ],
          tasks: [
            {
              id: 1,
              created_at: Date.yesterday,
              updated_at: Date.today,
              due_on: Date.tomorrow,
              status: :pending,
              type: "VerifyInformation"
            }
          ]
        }
      end
    end
  end
end
