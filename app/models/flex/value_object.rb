module Flex
  class ValueObject
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::AttributeAssignment
    include ActiveModel::Validations
    include ActiveModel::Serializers::JSON

    def ==(other)
      return false if self.class != other.class
      attributes == other.attributes
    end
  end
end
