# frozen_string_literal: true

module Strata::Flows
  # Represents an informational page with no form inputs.
  class InfoPage
    include Rails.application.routes.url_helpers
    attr_accessor :name, :context, :loop

    def initialize(name, if: nil, context: nil, loop: nil)
      reserved_attributes = { if: }

      @name = name
      @if = reserved_attributes[:if]
      @context = context || @name.to_sym
      @loop = loop
    end

    def in_loop?
      @loop.present?
    end

    def needed?(record)
      @if.blank? || @if.call(record)
    end

    def completed?(record)
      record.valid?(@context)
    end

    def pathname
      in_loop? ? "#{@loop.name}_#{@name}" : @name
    end

    def pathnames
      [ pathname ]
    end

    def path(flow_record, loop_record = nil)
      if in_loop?
        send(
          "#{pathname}_#{flow_record.class.name.underscore}_#{@loop.association.to_s.singularize}_path",
          flow_record, loop_record
        )
      else
        send("#{pathname}_#{flow_record.class.name.underscore}_path", flow_record)
      end
    end
  end
end
