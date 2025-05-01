module Flex
  module Attributes
    extend ActiveSupport::Concern

    class_methods do
      def flex_attribute(name, type, options = {})
        if type == :memorable_date
          memorable_date_attribute name, options
        else
          raise ArgumentError, "Unsupported attribute type: #{type}"
        end
      end

      private

        def memorable_date_attribute(name, options)
          attribute name, :string

          validate :"validate_#{name}"

          if options[:presence]
            validates name, presence: true
          end

          # Create a writer method that accepts a Date,
          # a Hash of with keys :year, :month, :day,
          # or a String in the format "YYYY-MM-DD"
          # (the String doesn't have to have that format at this point
          # but it will be validated later as part of the validation method)
          define_method "#{name}=" do |value|
            case value
            when Date
              super(value.strftime("%Y-%m-%d"))
            when Hash
              super("%04d-%02d-%02d" % [ value[:year], value[:month], value[:day] ])
            when String
              super(value)
            else
              raise ArgumentError, "Invalid value for #{name}: #{value.inspect}. Expected Date, Hash, or String."
            end
          end

          # Create a validation method that checks if the value is a valid date
          define_method "validate_#{name}" do
            value = send(name)
            return if value.nil?

            begin
              Date.strptime(value, "%Y-%m-%d")
            rescue Date::Error
              errors.add(name, :invalid_date, message: "is not a valid date")
            end
          end
        end
    end
  end
end
