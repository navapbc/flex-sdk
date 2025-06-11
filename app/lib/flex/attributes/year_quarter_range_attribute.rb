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

          define_method name do
            start_yq = send("#{name}_start")
            end_yq = send("#{name}_end")

            if start_yq.nil? || end_yq.nil?
              nil
            else
              Range.new(start_yq, end_yq)
            end
          end

          define_method "#{name}=" do |period|
            case period
            when Range
              send("#{name}_start=", period.begin)
              send("#{name}_end=", period.end)
            when nil
              send("#{name}_start=", nil)
              send("#{name}_end=", nil)
            end
          end

          validate :"validate_#{name}_range"

          define_method "validate_#{name}_range" do
            start_yq = send("#{name}_start")
            end_yq = send("#{name}_end")

            if start_yq.present? && end_yq.present? && start_yq > end_yq
              errors.add(name, :invalid_year_quarter_range,
                message: "start must be before or equal to end")
            end
          end
        end
      end
    end
  end
end
