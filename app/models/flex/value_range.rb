module Flex
  # A generic range class that represents an inclusive range between two values of the same type.
  # It provides validation, comparison, and serialization functionality for ranges.
  class ValueRange < Flex::ValueObject

    # start and end attributes are defined dynamically based on the value_class
    # (see ValueRange.[] method)

    flex_validates_nested :start
    flex_validates_nested :end
    validate :start_cannot_be_greater_than_end

    def include?(value)
      value >= start && value <= self.end
    end

    def attributes
      {
        start: start,
        end: self.end,
      }
    end

    def self.[](value_class)
      if value_class == Date
        raise ArgumentError, "Use Flex::ValueRange[Flex::USDate] or Flex::DateRange instead of Flex::ValueRange[Date]"
      end

      @value_range_classes ||= {}
      @value_range_classes[value_class] ||= Class.new(self) do
        value_type = value_class.name.demodulize.underscore.to_sym
        flex_attribute :start, value_type
        flex_attribute :end, value_type

        define_singleton_method(:value_class) { value_class }
      end
    end

    private

    def start_cannot_be_greater_than_end
      if start && self.end && start > self.end
        errors.add(:base, start_greater_than_end_error_type)
      end
    end

    def start_greater_than_end_error_type
      :"#{self.class.value_class.name.demodulize.underscore}_range_start_greater_than_end"
    end
  end
end
