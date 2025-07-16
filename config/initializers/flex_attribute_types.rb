ActiveSupport.on_load(:active_record) do
  require_relative "../../lib/flex/types/name_type"
  ActiveRecord::Type.register(:name, Flex::Types::NameType)
end
