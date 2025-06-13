module Flex
  module Attributes
    # YearQuarterRangeAttribute provides a DSL for defining year quarter range attributes in form models.
    # It uses Ruby's native Range class with manual getter/setter methods to map start and end
    # year_quarter columns to a single range attribute.
    #
    # @example Adding a year quarter range attribute to a form model
    #   class MyForm < Flex::ApplicationForm
    #     include Flex::Attributes::YearQuarterRangeAttribute
    #     year_quarter_range_attribute :base_period
    #   end
    #
    # Key features:
    # - Uses Ruby's native Range class
    # - Maps start/end year_quarter attributes to Range#begin and Range#end
    # - Validates that start year_quarter <= end year_quarter
    # - Handles Range input conversion
    module YearQuarterRangeAttribute
      extend ActiveSupport::Concern

      class_methods do
        def year_quarter_range_attribute(name, options = {})
          flex_attribute "#{name}_start", :year_quarter
          flex_attribute "#{name}_end", :year_quarter

          define_method(name) do
            start_yq = send("#{name}_start")
            end_yq = send("#{name}_end")

            if start_yq.nil? || end_yq.nil?
              nil
            else
              Range.new(start_yq, end_yq)
            end
          end

          define_method("#{name}=") do |value|
            case value
            when YearQuarterRange
              send("#{name}_start=", value.start)
              send("#{name}_end=", value.end)
            when Range
              send("#{name}_start=", value.begin)
              send("#{name}_end=", value.end)
            when nil
              send("#{name}_start=", nil)
              send("#{name}_end=", nil)
            end
          end

          validate :"validate_#{name}"

          # TODO
          # This looks like it could be generalized into a "nested object" validator
          define_method "validate_#{name}" do
            range = send(name)
            if range && range.invalid?
              range.errors.each do |error|
                if error.attribute == :base
                  errors.add(name, error.type)
                else
                  errors.add("#{name}_#{attribute}", error.type)
                end
              end
            end
          end
        end
      end
    end
  end
end
