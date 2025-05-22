module Flex
  class TasksController < ApplicationController
    helper DateHelper

    def task_class
      Flex::Task
    end

    def user_class
      Flex::User
    end

    def application_form_class
      Flex::ApplicationForm
    end

    def index
      filter_tasks
      @distinct_task_types = task_class.distinct.pluck(:type)
    end

    def show
      @task = task_class.find(params[:id])
      @assigned_user = user_class.find(@task.assignee_id) if @task.assignee_id
      @application_form = application_form_class.find_by(case_id: @task.case_id)
    end

    def update
      @task = task_class.find(params[:id])
      if params["task-action"].present?
        @task.mark_completed
        flash["task-message"] = I18n.t("tasks.messages.task_marked_completed")
      end

      redirect_to task_path(@task)
    end

    private
    def index_filter_params
      params.permit(:filter_date, :filter_type, :filter_status)
    end

    def filter_tasks
      if index_filter_params[:filter_date].present?
        @tasks = filter_tasks_by_date(index_filter_params[:filter_date])
      end
      if index_filter_params[:filter_type].present?
        @tasks = filter_tasks_by_type(index_filter_params[:filter_type])
      end
      @tasks = filter_tasks_by_status
    end

    def filter_tasks_by_date(filter_by)
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
          tasks.all
      end
    end

    def filter_tasks_by_type(filter_by)
      filter_by == "all" ? task_class.all : task_class.with_type(filter_by)
    end

    def filter_tasks_by_status
      index_filter_params[:filter_status] == "completed" \
        ? task_class.completed
        : task_class.incomplete
    end
  end
end
