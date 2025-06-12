module Flex
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

    def to_h
      {
        start: @start.respond_to?(:to_h) ? @start.to_h : @start,
        end: @end.respond_to?(:to_h) ? @end.to_h : @end
      }
    end

    def self.from_h(hash)
      start_h = hash[:start] || hash["start"]
      end_h = hash[:end] || hash["end"]
      value_class = self.value_class
      start = value_class.respond_to?(:from_h) ? value_class.from_h(start_h) : value_class.parse(start_h)
      end_value = value_class.respond_to?(:from_h) ? value_class.from_h(end_h) : value_class.parse(end_h)
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
