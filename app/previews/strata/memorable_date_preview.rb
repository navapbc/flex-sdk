module Strata
  # MemorableDatePreview provides preview examples for the memorable date component.
  # It demonstrates different states of the date input fields including empty,
  # filled, and invalid states.
  #
  # This class is used with Lookbook to generate UI component previews
  # for the memorable date form component.
  #
  # @example Viewing the filled state preview
  #   # In Lookbook UI
  #   # Navigate to Strata > MemorableDatePreview > filled
  #
  class MemorableDatePreview < Lookbook::Preview
    layout "component_preview"

    def empty
      render template: "strata/previews/_memorable_date", locals: { model: new_model }
    end

    def filled
      model = new_model
      model.date_of_birth = Date.new(1990, 2, 28)
      render template: "strata/previews/_memorable_date", locals: { model: model }
    end

    def invalid
      model = new_model
      model.date_of_birth = { year: 1990, month: 2, day: 31 }
      model.valid?
      render template: "strata/previews/_memorable_date", locals: { model: model }
    end

    private

    def new_model
      @model = Class.new do
        include ActiveModel::Model
        include ActiveModel::Attributes
        include ActiveModel::Validations

        attribute :date_of_birth, :date

        validate :date_of_birth_is_valid

        def self.model_name
          ActiveModel::Name.new(self, nil, "TestModel")
        end

        def date_of_birth_is_valid
          if date_of_birth_before_type_cast.present? && date_of_birth.nil?
            errors.add(:date_of_birth, :invalid_date)
          end
        end

        # Simulate the behavior of ActiveRecord's before_type_cast

        def date_of_birth=(value)
          @date_of_birth_before_type_cast = value
          super
        end

        def date_of_birth_before_type_cast
          @date_of_birth_before_type_cast
        end
      end.new
    end
  end
end
