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

      # @param task [Strata::Task] the task being shown
      # @param assigned_user_display_text [String, nil] display name for the task's assignee.
      #   Only read when the component falls back to its default +task_info+ row — that is,
      #   when no +task_info:+ constructor arg and no +task_info_content+ slot is provided.
      #   Otherwise it is unused and may be omitted.
      # @param task_info [Array<Hash>, nil] an array of +{label:, value:}+ hashes.
      #   When nil, a default row (status / due / assignee) is rendered.
      # @param breadcrumbs [Array<Hash>, nil] array of +{text:, link:}+ hashes. When nil, a
      #   default Home / Tasks / <task type> trail is rendered.
      # @param task_details_partial [String, nil] partial path to render in the details section.
      #   When nil, falls back to +details/<task_type_underscored>+ resolved via the controller's
      #   prepended view paths.
      # @param details_locals [Hash] extra locals forwarded to the details partial
      #   (e.g. +application_form:+, +kase:+). Merged on top of +task+, which the
      #   component always passes.
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
          { text: t("strata.tasks.breadcrumbs.home"), link: "/" },
          {
            text: t("strata.tasks.breadcrumbs.tasks"),
            link: helpers.url_for(only_path: true, action: :index)
          },
          { text: t("tasks.types.#{task.type.underscore}") }
        ]
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
        { task: task }.merge(details_locals)
      end
    end
  end
end
