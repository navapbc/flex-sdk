module Strata
  # A generic range class that represents an inclusive range between two values of the same type.
  # It provides validation, comparison, and serialization functionality for ranges.
  class ValueRange < Strata::ValueObject
    # start and end attributes are defined dynamically based on the value_class
    # (see ValueRange.[] method)

    strata_validates_nested :start
    strata_validates_nested :end
    validate :start_cannot_be_greater_than_end

    def include?(value)
      value >= start && value <= self.end
    end

    def attributes
      {
        start: start,
        end: self.end
      }
    end

    def self.[](value_class)
      if value_class == Date
        raise ArgumentError, "Use Strata::ValueRange[Strata::USDate] or Strata::DateRange instead of Strata::ValueRange[Date]"
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
      return unless start && self.end

      # Don't try to validate whether start > end if the start or end are
      # themselves already invalid, since that may throw objects not
      # comparable errors.

      # TODO it seems inefficient to run nested validations again here
      return if start.respond_to?(:invalid?) && start.invalid?
      return if self.end.respond_to?(:invalid?) && self.end.invalid?

      if start > self.end
        errors.add(:base, start_greater_than_end_error_type)
      end
    end

    def start_greater_than_end_error_type
      :"#{self.class.value_class.name.demodulize.underscore}_range_start_greater_than_end"
    end
  end
end
