module Flex
  module TasksHelper
    def distinct_task_type_options
      task_types = Flex::Task.select_distinct_task_types.map do |type|
        [ type.underscore.humanize, type ]
      end

      task_types.unshift([ "All tasks", "all" ])
    end

    def humanize_task_type(type)
      type.underscore.humanize
    end

    def hidden_params_field(name)
      hidden_field_tag(name, params[name]) if params[name].present?
    end

    def tabs_configuration(model_class)
      [
          { name: "Assigned", path: polymorphic_path(model_class, filter_status: nil, filter_date: params[:filter_date], filter_type: params[:filter_type]), active: params[:filter_status] != "completed" },
          { name: "Completed", path: polymorphic_path(model_class, filter_status: "completed", filter_date: params[:filter_date], filter_type: params[:filter_type]), active: params[:filter_status] == "completed" }
      ]
    end
  end
end
