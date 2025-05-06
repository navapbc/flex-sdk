class PassportTasksController < ApplicationController
  def index
    if index_filter_params[:filter_date].present?
      @tasks = filter_tasks_by_date(@tasks || Flex::Task, index_filter_params[:filter_date])
    end
    if index_filter_params[:filter_type].present?
      @tasks = filter_tasks_by_type(@tasks || Flex::Task, index_filter_params[:filter_type])
    end

    (@tasks ||= Flex::Task.all).order_by_due_on_desc
  end

  def new
  end

  def create
  end

  def show
    @case = PassportCase.find(params[:id])
  end

  def edit
  end

  def update
  end

  def model_class
    controller_path.classify.constantize
  end

  private

  def index_filter_params
    params.permit(:filter_date, :filter_type)
  end

  def filter_tasks_by_date(tasks, filter_by)
    case filter_by
    when "today"
        tasks.filter_by_due_on(Date.today)
    when "overdue"
        tasks.filter_by_due_on_before(Date.today)
    when "tomorrow"
        tasks.filter_by_due_on(Date.tomorrow)
    when "this_week"
        tasks.filter_by_due_on_range(Date.today.beginning_of_week, Date.today.end_of_week)
    else
        tasks.all
    end
  end

  def filter_tasks_by_type(tasks, filter_by)
    Tasks.distinct_task_types.include?(filter_by) \
      ? tasks.filter_by_type(filter_by)
      : tasks.all
  end
end
