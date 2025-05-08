module Flex
  module TasksHelper
    def find_task_type_human_readable_name(task_type_map, task_type)
      _, human_readable_name = task_type_map.find { |type, _| type.name == task_type }

      human_readable_name
    end

    def task_type_options_for_select(task_type_map = {}, selected = nil)
      safe_join([
        tag.option("All tasks", value: ""),
        task_type_map.map do |task_type, human_readable_task_type|
          tag.option(
            human_readable_task_type,
            value: task_type.name,
            selected: task_type.name == selected
          )
        end
      ])
    end

    def hidden_params_field(name)
      hidden_field_tag(name, params[name]) if params[name].present?
    end
  end
end
