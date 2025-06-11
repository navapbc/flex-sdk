module Flex
  class ValueRange
    attr_reader :start, :end

    def initialize(start, end_value)
      raise ArgumentError, "Start value must be less than or equal to end value" if start > end_value

      @start = start
      @end = end_value
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
      start = self.class.value_class.from_h(start_h)
      end_value = self.class.value_class.from_h(start_h)
      new(start, end_value)
    end

    def ==(other)
      other.is_a?(ValueRange) && @start == other.start && @end == other.end
    end

    def self.[](klass)
      Class.new(self) do
        class << self
          def value_class
            klass
          end
        end
      end
    end
  end  
end
