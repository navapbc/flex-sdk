module PassportTasksHelper
  def mm_dd_yyyy(date)
    date.strftime("%m/%d/%Y")
  end

  def time_since_epoch(date)
    date.to_time.to_i
  end

  def distinct_task_type_options
    task_types = Flex::Task.select_distinct_task_types.map do |type|
      [type.underscore.humanize, type]
    end

    task_types.unshift(["All tasks", "all"])
  end

  def humanize_task_type(type)
    type.underscore.humanize
  end

  def hidden_params_field(name)
    hidden_field_tag(name, params[name]) if params[name].present?
  end
end