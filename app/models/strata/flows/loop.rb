# frozen_string_literal: true

module Strata::Flows
  # Represents a sequence of question pages that iterates over a has_many
  # association on the flow record. Each child record is walked through the
  # same set of pages before the cursor advances to the next child.
  class Loop
    attr_accessor :name, :association, :pages

    def initialize(name, association: nil, pages: [])
      @name = name
      @association = association || name
      @pages = pages
    end

    def records_for(flow_record)
      flow_record.public_send(@association)
    end

    def record_class(flow_record)
      flow_record.class.reflect_on_association(@association).klass
    end

    def started?(flow_record)
      records_for(flow_record).any? do |child|
        @pages.any? { |page| page.completed?(child) }
      end
    end

    def completed?(flow_record)
      records_for(flow_record).all? do |child|
        @pages.all? { |page| page.completed?(child) }
      end
    end
  end
end
