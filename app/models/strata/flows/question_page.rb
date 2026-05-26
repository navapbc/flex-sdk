# frozen_string_literal: true

module Strata::Flows
  # Represents an individual question page with a set of input fields.
  class QuestionPage
    include Rails.application.routes.url_helpers
    attr_accessor :name, :fields

    def initialize(name, if: nil, fields: nil)
      reserved_attributes = { if: }

      @name = name
      @if = reserved_attributes[:if]
      @fields = fields || [ @name.to_sym ]
    end

    def needed?(record)
      @if.blank? || @if.call(record)
    end

    def completed?(record)
      record.valid?(@name.to_sym)
    end

    def started?(record)
      @fields.any? do |field|
        field_names = field.is_a?(Hash) ? field.keys : [ field ]
        field_names.any? do |name|
          # Fields for accepts_nested_attributes_for associations are declared as
          # :foo_attributes (matching the foo_attributes= setter used by form
          # params), but only the bare association reader (record.foo) exists.
          # Strip the suffix so we probe the actual association.
          attribute_name = name.to_s.delete_suffix("_attributes")
          record.public_send(attribute_name).present?
        end
      end
    end

    def edit_pathname
      "edit_#{@name}"
    end

    def edit_path(record)
      send("#{edit_pathname}_#{record.class.name.underscore}_path", record)
    end

    def update_pathname
      "update_#{@name}"
    end

    def update_path(record)
      send("#{update_pathname}_#{record.class.name.underscore}_path", record)
    end

    # Returns the list of permitted parameter keys for this page's fields,
    # expanding strata attributes into their component columns.
    #
    # @param record_klass [Class<ActiveRecord::Base>] a model class that defines strata attributes
    # @return [Array<Symbol, Hash>] flat parameter keys and multi-parameter hashes
    def attributes(record_klass)
      registry = record_klass.try(:strata_attributes_registry) || {}

      @fields.flat_map do |field|
        registry[field] || [ field ]
      end
    end
  end
end
