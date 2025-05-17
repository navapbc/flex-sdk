module Flex
  module Attributes
    class NameValue
      include ActiveModel::Validations

      attr_reader :first, :middle, :last

      validates :first, presence: true
      validates :last, presence: true

      def initialize(first, middle, last)
        @first = first
        @middle = middle
        @last = last
      end

      def ==(other)
        return false unless other.is_a?(NameValue)
        first == other.first && middle == other.middle && last == other.last
      end

      def to_s
        [ first, middle, last ].compact.join(" ")
      end
    end
  end
end
