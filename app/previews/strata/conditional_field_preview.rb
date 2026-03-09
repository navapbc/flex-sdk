# frozen_string_literal: true

module Strata
  # ConditionalFieldPreview provides preview examples for the conditional form field helper.
  # It demonstrates showing/hiding form fields based on radio button selections.
  #
  # @example Viewing the yes_no preview
  #   # In Lookbook UI
  #   # Navigate to Strata > ConditionalFieldPreview > yes_no
  #
  class ConditionalFieldPreview < Lookbook::Preview
    layout "strata/component_preview"

    # @label Yes/No conditional
    def yes_no
      render template: "strata/previews/_conditional_field_yes_no", locals: { model: new_model }
    end

    # @label Yes/No with pre-selected value
    def yes_no_prefilled
      model = new_model
      model.has_employer = "true"
      model.employer_name = "Acme Corp"
      render template: "strata/previews/_conditional_field_yes_no", locals: { model: model }
    end

    # @label Multiple radio options
    def radio_options
      render template: "strata/previews/_conditional_field_radio_options", locals: { model: new_model }
    end

    private

    def new_model
      Class.new do
        include ActiveModel::Model
        include ActiveModel::Attributes

        attribute :has_employer, :string
        attribute :employer_name, :string
        attribute :leave_type, :string
        attribute :medical_provider, :string
        attribute :other_reason, :string

        def self.model_name
          ActiveModel::Name.new(self, nil, "TestModel")
        end
      end.new
    end
  end
end
