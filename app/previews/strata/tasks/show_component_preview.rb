# frozen_string_literal: true

module Strata
  module Tasks
    # Lookbook preview for the ShowComponent.
    #
    # The component's defaults rely on routing and view-path setup that
    # +Strata::TasksController+ provides at request time (notably
    # +helpers.url_for(action: :index)+ for the breadcrumbs and the
    # +details/<task_type>+ partial lookup). These previews pass
    # +breadcrumbs:+ explicitly and use the +task_details_content+ slot
    # so they render correctly in Lookbook's controller context.
    class ShowComponentPreview < ViewComponent::Preview
      def default
        task = build_preview_task

        render ShowComponent.new(
          task: task,
          assigned_user_display_text: "Jane Doe",
          breadcrumbs: preview_breadcrumbs
        ) do |c|
          c.with_task_details_content { stub_task_details }
        end
      end

      def with_custom_task_info
        task = build_preview_task

        render ShowComponent.new(
          task: task,
          breadcrumbs: preview_breadcrumbs,
          task_info: [
            { label: "Status:", value: "Pending" },
            { label: "Due On:", value: "07/01/2026" },
            { label: "Assigned To:", value: "Unassigned" },
            { label: "Priority:", value: "High" }
          ]
        ) do |c|
          c.with_task_details_content { stub_task_details }
        end
      end

      private

      def build_preview_task
        PassportPhotoTask.new(due_on: 1.week.from_now)
      end

      def preview_breadcrumbs
        [
          { text: "Home", link: "/" },
          { text: "Tasks", link: "/staff/tasks" },
          { text: "Review Passport Photo" }
        ]
      end

      def stub_task_details
        <<~HTML.html_safe
          <div class="usa-prose">
            <h3>Task Details</h3>
            <p>The task-type-specific details partial renders in this section.</p>
          </div>
        HTML
      end
    end
  end
end
