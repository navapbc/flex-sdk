ActiveSupport.on_load(:active_record) do
  ActiveRecord::Type.register(:name, Flex::Types::NameType)
end
