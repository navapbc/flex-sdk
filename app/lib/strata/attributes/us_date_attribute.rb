module Strata
  module Attributes
    # This module provides a custom ActiveRecord type for handling dates in a US format.
    # It allows dates to be stored in a format that is consistent with US conventions
    module USDateAttribute
      extend ActiveSupport::Concern
      include Validations

      def self.attribute_type
        :single_column_value_object
      end

      # A custom ActiveRecord type that allows storing a date. It behaviors the same
      # as the default Date type, but when casting a string it uses the US regional
      # format (MM/DD/YYYY) instead of default heuristics used by Date.parse which can
      # incorrectly interpret dates as DD/MM/YYYY.
      class USDateType < ActiveModel::Type::Date
        # Override cast to allow setting the date via a Hash with keys :year, :month, :day.
        def cast(value)
          Strata::USDate.cast(value)
        end

        def type
          :us_date
        end
      end

      class_methods do
        def us_date_attribute(name, options)
          attribute name, USDateType.new
          flex_validates_type_casted_attribute(name, :invalid_date)
        end
      end
    end
  end
end
