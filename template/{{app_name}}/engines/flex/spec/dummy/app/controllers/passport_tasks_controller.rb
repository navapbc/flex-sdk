class PassportTasksController < ApplicationController
  helper Flex::TasksHelper

  def index
    filter_tasks
  end

  def model_class
    controller_path.classify.constantize
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
    @tasks = tasks.order_by_due_on_desc
  end

  def filter_tasks_by_date(filter_by)
    case filter_by
    when "today"
        tasks.where_due_on(Date.today)
    when "overdue"
        tasks.where_due_on_before(Date.today)
    when "tomorrow"
        tasks.where_due_on(Date.tomorrow)
    when "this_week"
        tasks.where_due_on_between(Date.today.beginning_of_week, Date.today.end_of_week)
    else
        tasks.all
    end
  end

  def filter_tasks_by_type(filter_by)
    tasks.select_distinct_task_types.include?(filter_by) \
      ? tasks.where_type(filter_by)
      : tasks.all
  end

  def filter_tasks_by_status
    index_filter_params[:filter_status] == "completed" \
      ? tasks.where_completed
      : tasks.where_not_completed
  end
end
