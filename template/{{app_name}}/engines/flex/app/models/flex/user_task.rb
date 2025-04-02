require_relative '../concerns/step'
module Flex
  class UserTask
    include Step
    include ActiveModel::Model
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend ActiveModel::Naming

    validates :name, presence: true

    def persisted?
      false
    end
  end
end
