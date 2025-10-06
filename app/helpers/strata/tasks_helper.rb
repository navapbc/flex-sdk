# frozen_string_literal: true

module Strata
  # TasksHlerp provides view helpers for working with Strata::Task objects.
  # This module is used in views to render task-related UI components.
  module TasksHelper
    def task_filter_params
      params.permit(:filter_date, :filter_type, :filter_status)
    end

    def task_tabs
      [
        {
          name: t("strata.tasks.index.tabs.assigned"),
          path: url_for(task_filter_params.merge(filter_status: nil)),
          active: params[:filter_status] != "completed"
        },
        {
          name: t("strata.tasks.index.tabs.completed"),
          path: url_for(task_filter_params.merge(filter_status: "completed")),
          active: params[:filter_status] == "completed"
        }
      ]
    end
  end
end
