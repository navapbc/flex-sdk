module Flex
  class Name
    include ActiveModel::Model
    include Comparable

    attr_reader :first, :middle, :last

    def initialize(first, middle, last)
      @first = first
      @middle = middle
      @last = last
    end

    def <=>(other)
      [ first, middle, last ] <=> [ other.first, other.middle, other.last ]
    end

    def full_name
      [ first, middle, last ].compact.join(" ")
    end

    def persisted?
      false
    end
  end
end
