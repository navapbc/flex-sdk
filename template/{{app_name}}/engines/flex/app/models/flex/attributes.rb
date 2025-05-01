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

          define_method "#{name}=" do |value|
            case value
            when Date
              super(value.strftime('%Y-%m-%d'))
            when Hash
              super("%04d-%02d-%02d" % [value[:year], value[:month], value[:day]])
            when String
              super(value)
            else
              raise ArgumentError, "Invalid value for #{name}: #{value.inspect}. Expected Date, Hash, or String."
            end
          end

          define_method "validate_#{name}" do
            value = send(name)
            return if value.nil?

            # If value is a Date, it is already valid
            return if value.is_a?(Date)

            begin
              Date.strptime(value, '%Y-%m-%d')
            rescue Date::Error
              errors.add(name, :invalid_date, message: "is not a valid date")
            end
          end
        end
    end
  end
end
