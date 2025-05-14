module Flex
  module TasksHelper
    def hidden_params_field(name)
      hidden_field_tag(name, params[name]) if params[name].present?
    end
  end
end
