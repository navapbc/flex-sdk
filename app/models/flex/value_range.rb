module Flex
  # A generic range class that represents an inclusive range between two values of the same type.
  # It provides validation, comparison, and serialization functionality for ranges.
  class ValueRange
    include ActiveModel::Model

    attr_reader :start, :end

    validates_date :start, allow_blank: true
    validates_date :end, allow_blank: true
    validate :start_cannot_be_greater_than_end

    def initialize(start, end_value)
      @start = start
      @end = end_value
    end

    def start_cannot_be_greater_than_end
      if start && self.end && start > self.end
        errors.add(:base, start_greater_than_end_error_type)
      end
    end

    def start_greater_than_end_error_type
      :"#{self.class.value_class.name.downcase}_range_start_greater_than_end"
    end

    def include?(value)
      value >= @start && value <= @end
    end

    def as_json
      {
        start: @start.respond_to?(:as_json) ? @start.as_json : @start,
        end: @end.respond_to?(:as_json) ? @end.as_json : @end
      }
    end

    def self.from_hash(hash)
      start_h = hash[:start] || hash["start"]
      end_h = hash[:end] || hash["end"]
      value_class = self.value_class
      start = value_class.respond_to?(:from_hash) ? value_class.from_hash(start_h) : start_h
      end_value = value_class.respond_to?(:from_hash) ? value_class.from_hash(end_h) : end_h
      new(start, end_value)
    end

    def ==(other)
      other.is_a?(ValueRange) && @start == other.start && @end == other.end
    end

    def self.[](value_class)
      Class.new(self) do
        define_singleton_method(:value_class) { value_class }
      end
    end
  end
end
