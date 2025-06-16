module Flex
  # A generic range class that represents an inclusive range between two values of the same type.
  # It provides validation, comparison, and serialization functionality for ranges.
  class ValueRange
    include ActiveModel::Model

    attr_reader :start, :end

    validate :validate_start
    validate :validate_end
    validate :start_cannot_be_greater_than_end

    def initialize(start_value, end_value)
      raise TypeError, "Expected #{self.class.value_class.name} for start, got #{start_value.class.name}" unless start_value.is_a?(self.class.value_class) || start_value.nil?
      raise TypeError, "Expected #{self.class.value_class.name} for end, got #{end_value.class.name}" unless end_value.is_a?(self.class.value_class) || end_value.nil?

      @start = start_value
      @end = end_value
    end

    def include?(value)
      value >= @start && value <= @end
    end

    def as_json
      {
        start: @start.as_json,
        end: @end.as_json
      }
    end

    def self.from_hash(hash)
      raise TypeError unless hash.is_a?(Hash)
      start_hash = hash[:start] || hash["start"]
      end_hash = hash[:end] || hash["end"]
      raise ArgumentError, "Missing start or end value" unless start_hash && end_hash
      start_value = self.parse_nested_attribute(start_hash)
      end_value = self.parse_nested_attribute(end_hash)
      new(start_value, end_value)
    end

    def self.parse_nested_attribute(value)
      if self.value_class.respond_to?(:from_hash)
        self.value_class.from_hash(value)
      elsif self.value_class.respond_to?(:parse)
        self.value_class.parse(value)
      else
        value
      end
    end

    def ==(other)
      other.is_a?(ValueRange) && @start == other.start && @end == other.end
    end

    def self.[](value_class)
      @value_range_classes ||= {}
      @value_range_classes[value_class] ||= Class.new(self) do
        define_singleton_method(:value_class) { value_class }
      end
    end

    private

    def validate_start
      # TODO(https://linear.app/nava-platform/issue/TSS-149/generalize-nested-object-validator)
      # figure out how to validate nested attribute
    end

    def validate_end
      # TODO(https://linear.app/nava-platform/issue/TSS-149/generalize-nested-object-validator)
      # figure out how to validate nested attribute
    end

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
