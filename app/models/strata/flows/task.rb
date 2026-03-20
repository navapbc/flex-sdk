# frozen_string_literal: true

module Strata::Flows
  # Represents a set of related questions as a task within a flow.
  class Task
    attr_accessor :name, :pages, :depends_on

    def initialize(name, depends_on: nil, pages: [])
      @name = name
      @depends_on = depends_on
      @pages = pages
    end

    def started?(record)
      @pages.any? { |page| page.completed?(record) }
    end

    def completed?(record)
      @pages.all? { |page| page.completed?(record) }
    end

    def dependencies_met?(flow)
      flow.dependencies_met?(@depends_on, exclude: @name)
    end

    # Returns the current workable page if in-progress, or the first page otherwise.
    def path(record)
      return nil if @pages.empty?

      if !started?(record) || completed?(record)
        @pages.first.edit_path(record)
      else
        @pages.find { |page| !page.completed?(record) }.edit_path(record)
      end
    end
  end
end
