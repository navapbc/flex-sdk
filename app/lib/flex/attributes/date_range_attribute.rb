module Flex
  module Attributes
    module DateRangeAttribute
      extend ActiveSupport::Concern
      class_methods do
        def date_range_attribute(name, options)
          # Create the start and end date attributes
          attribute "#{name}_start", :date
          attribute "#{name}_end", :date

          # Add validation for the range
          validate :"validate_#{name}"

          # Set up the composed_of relationship
          composed_of name,
            class_name: "Range",
            mapping: [
              [ "#{name}_start", "begin" ],
              [ "#{name}_end", "end" ]
            ],
            allow_nil: true,
            converter: Proc.new { |value|
              case value
              when Hash
                if value[:start].present? && value[:end].present?
                  start_date_s = value[:start].to_s
                  end_date_s = value[:end].to_s
                  start_date = DateRangeAttribute.try_parse_local_date(start_date_s) || DateRangeAttribute.try_parse_iso_date(start_date_s)
                  end_date = DateRangeAttribute.try_parse_local_date(end_date_s) || DateRangeAttribute.try_parse_iso_date(end_date_s)
                  start_date..end_date
                else
                  nil
                end
              else
                nil
              end
            }

          # Create validation method for the range
          define_method "validate_#{name}" do
            start_date = send("#{name}_start")
            end_date = send("#{name}_end")

            # Allow both nil (entire range is nil) but not one nil and one present
            if (start_date.nil? && !end_date.nil?) || (!start_date.nil? && end_date.nil?)
              errors.add(name, :invalid_date_range_nil)
              return
            end

            # Skip validation if both are nil
            return if start_date.nil? && end_date.nil?

            # Validate that start date is less than or equal to end date
            if start_date > end_date
              errors.add(name, :invalid_date_range)
            end
          end
        end
      end

      class << self
        def try_parse_local_date(date_string)
          begin
            Date.strptime(date_string, "%m/%d/%Y")
          rescue ArgumentError
            nil
          end
        end

        def try_parse_iso_date(date_string)
          begin
            Date.strptime(date_string, "%Y-%m-%d")
          rescue ArgumentError
            nil
          end
        end
      end
    end
  end
end
