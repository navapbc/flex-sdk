class PassportTasksController < ApplicationController
  helper Flex::TasksHelper
  helper Flex::DateHelper

  def index
    filter_tasks
  end

  def show
    @task = tasks.find(params[:id])
    @assigned_user = User.find(@task.assignee_id) if @task.assignee_id
    @application_form = PassportApplicationForm.find_by(case_id: @task.case_id)
  end

  private
  def index_filter_params
    params.permit(:filter_date, :filter_type, :filter_status)
  end

  def tasks
    @tasks ||= Flex::Task
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
    filter_by == "all" ? tasks.all : tasks.with_type(filter_by)
  end

  def filter_tasks_by_status
    index_filter_params[:filter_status] == "completed" \
      ? tasks.completed
      : tasks.incomplete
  end
end
