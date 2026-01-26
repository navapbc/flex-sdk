# frozen_string_literal: true

module Strata
  module Flows
    # TaskSectionComponent renders the status of an individual section (task) within a task list.
    #
    # ## Customizing Step Descriptions
    #
    # Step descriptions can be customized by setting locale keys in the format:
    #   `{application_form_class_plural}.task_section_component.{task_name}`
    #    Example: `paid_leave_application_forms.task_section_component.personal_information`
    #
    # @example Basic usage
    #   <%= render TaskSectionComponent.new(flow: @flow, task: @task) %>
    #
    class TaskSectionComponent < ViewComponent::Base
      def initialize(
        flow:,
        task:,
        show_step_label: false
      )
        @flow = flow
        @task = task
        @show_step_label = show_step_label
      end

      def translation_prefix
        "#{@flow.record.class.name.underscore.pluralize}.task_section_component.#{@task.name}"
      end

      # Renders the correct content within the task list to indicate the completion status of a step list task.
      def task_action
        if @task.completed?(@flow.record)
          content_tag(
            :div,
            content_tag(:svg, { class: "usa-icon text-success margin-right-05", "aria-hidden": "true", focusable: "false", role: "img"  }) do
              content_tag :use, nil, href: "/assets/img/sprite.svg#check"
            end.concat(
              t(".actions.completed")
            ),
            { class: "display-flex flex-align-center flex-justify-end" },
          ).concat(link_to(t(".actions.edit"), @task.path(@flow.record), class: "usa-link"))
        elsif @task.started?(@flow.record)
          link_to(
            t(".actions.continue"),
            @task.path(@flow.record),
            class: "usa-button usa-button--outline",
            method: :get
          )
        else
          link_to(
            t(".actions.start"),
            @task.path(@flow.record),
            class: "usa-button",
            method: :get
          )
        end
      end
    end
  end
end
