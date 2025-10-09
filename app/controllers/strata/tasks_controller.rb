# frozen_string_literal: true

module Strata
  # Controller for managing Strata::Task records. Handles listing, filtering, showing, and updating tasks.
  # This controller helps a parent application manage tasks by not forcing the parent application to implement the same functionality.
  class TasksController < ::StaffController
    helper DateHelper

    before_action :set_task, only: %i[ show update ]
    before_action :set_case, only: %i[ show update ]
    before_action :set_application_form, only: %i[ show update]
    before_action :add_task_details_view_path, only: %i[ show ]

    def index
      @task_types = Strata::Task.distinct(:type).unscope(:order).pluck(:type) # Postgres does not support using `order` with `distinct`, thus we have to unscope `order` here.
      @tasks = filter_tasks
      @unassigned_tasks = Strata::Task.incomplete.unassigned
    end

    def show
      @assignee = @task.assignee_id.present? ? User.find(@task.assignee_id) : nil
    end

    def update
      if params["task-action"].present?
        @task.completed!
        flash["task-message"] = I18n.t("tasks.messages.task_marked_completed")
      end

      redirect_to url_for(action: :show, id: @task.id)
    end

    def pick_up_next_task
      task = Strata::Task.assign_next_task_to(current_user.id)

      if task
        flash["task-message"] = I18n.t("strata.tasks.messages.task_picked_up")
        redirect_to url_for(action: :show, id: task.id)
      else
        flash["task-message"] = I18n.t("strata.tasks.messages.no_tasks_available")
        redirect_to url_for(action: :index)
      end
    end

    protected

    def filter_tasks
      tasks = filter_tasks_by_date(Strata::Task.all, index_filter_params[:filter_date])
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

    private

    def set_task
      @task = Strata::Task.find(params[:id]) if params[:id].present?
    end

    def set_case
      @case = @task.case if @task.present?
    end

    def set_application_form
      @application_form = @case.class.application_form_class.constantize.find(@case.application_form_id) if @case.present?
    end

    def add_task_details_view_path
      prepend_view_path "app/views/#{controller_path}"
    end

    def index_filter_params
      params.permit(:filter_date, :filter_type, :filter_status)
    end
  end
end
