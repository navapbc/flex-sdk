module Flex
  # Controller for managing Flex::Task records. Handles listing, filtering, showing, and updating tasks.
  # This controller helps a parent application manage tasks by not forcing the parent application to implement the same functionality.
  class TasksController < ::ApplicationController
    helper DateHelper

    before_action :set_task, only: %i[ show update ]
    before_action :add_task_details_view_path, only: %i[ show ]

    def index
      @task_types = Flex::Task.distinct(:type).unscope(:order).pluck(:type)
      @tasks = filter_tasks
    end

    def show
    end

    def update
      if params["task-action"].present?
        @task.mark_completed
        flash["task-message"] = I18n.t("tasks.messages.task_marked_completed")
      end

      redirect_to task_path(@task)
    end

    private

    def set_task
      @task = Flex::Task.find(params[:id]) if params[:id].present?
    end

    def add_task_details_view_path
      prepend_view_path "app/views/#{controller_path}"
    end

    def index_filter_params
      params.permit(:filter_date, :filter_type, :filter_status)
    end

    def filter_tasks
      tasks = filter_tasks_by_date(Flex::Task.all, index_filter_params[:filter_date])
      tasks = filter_tasks_by_type(tasks, index_filter_params[:filter_type])
      tasks = filter_tasks_by_status(tasks, index_filter_params[:filter_status])

      tasks
    end

    def filter_tasks_by_date(tasks, filter_by)
      case filter_by
      when "today"
        tasks.due_today
      when "overdue"
        tasks.overdue
      when "tomorrow"
        tasks.due_tomorrow
      when "this_week"
        tasks.due_this_week
      else
        tasks
      end
    end

    def filter_tasks_by_type(tasks, filter_by)
      return tasks unless filter_by.present? && filter_by != "all"

      tasks.with_type(filter_by)
    end

    def filter_tasks_by_status(tasks, status)
      status == "completed" \
        ? tasks.completed
        : tasks.incomplete
    end
  end
end
