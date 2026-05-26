# frozen_string_literal: true

module Strata
  module Tasks
    # ShowComponent renders the staff-facing task detail page: breadcrumbs, a heading,
    # task info row, optional flash banner, and a task-type-specific details section.
    #
    # @example Basic usage
    #   <%= render Strata::Tasks::ShowComponent.new(
    #     task: @task,
    #     assigned_user_display_text: @assignee&.full_name || "Not Assigned"
    #   ) %>
    #
    # @example Custom task_info row
    #   <%= render Strata::Tasks::ShowComponent.new(
    #     task: @task,
    #     assigned_user_display_text: "N/A",
    #     task_info: [{ label: "Custom", value: "Value" }]
    #   ) %>
    #
    # @example Full content override via slots
    #   <%= render Strata::Tasks::ShowComponent.new(task: @task, assigned_user_display_text: "N/A") do |c| %>
    #     <% c.with_breadcrumbs_content do %><nav>...</nav><% end %>
    #     <% c.with_task_details_content do %><section>...</section><% end %>
    #   <% end %>
    class ShowComponent < ViewComponent::Base
      renders_one :breadcrumbs_content
      renders_one :task_info_content
      renders_one :task_details_content

      def initialize(task:, assigned_user_display_text: nil,
                     task_info: nil, breadcrumbs: nil,
                     task_details_partial: nil, details_locals: {})
        @task = task
        @assigned_user_display_text = assigned_user_display_text
        @task_info = task_info
        @breadcrumbs = breadcrumbs
        @task_details_partial = task_details_partial
        @details_locals = details_locals
      end

      private

      attr_reader :task, :assigned_user_display_text, :task_info,
                  :breadcrumbs, :task_details_partial, :details_locals

      def default_breadcrumbs
        [
          { text: t("strata.tasks.breadcrumbs.home"), href: "/" },
          {
            text: t("strata.tasks.breadcrumbs.tasks"),
            href: helpers.url_for(only_path: true, action: :index)
          },
          { text: t("tasks.types.#{task.type.underscore}") }
        ]
      end

      # Normalize the legacy +link:+ key to +href:+ so downstream callers that
      # still pass +link:+ keep rendering as clickable links rather than spans.
      def breadcrumbs_items
        (breadcrumbs || default_breadcrumbs).map do |bc|
          bc.transform_keys { |k| k == :link ? :href : k }
        end
      end

      def default_task_info
        [
          { label: t("strata.tasks.show.details.status"),    value: t("tasks.statuses.#{task.status}") },
          { label: t("strata.tasks.show.details.due_on"),    value: helpers.local_en_us(task.due_on) },
          { label: t("strata.tasks.show.details.assigned_to"), value: assigned_user_display_text }
        ]
      end

      def task_message
        helpers.flash["task-message"]
      end

      def details_partial_path
        task_details_partial.presence || "details/#{task.type.underscore}"
      end

      def details_partial_locals
        details_locals.merge(task: task)
      end
    end
  end
end
