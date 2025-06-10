module Flex
  module Attributes
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
