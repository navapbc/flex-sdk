# frozen_string_literal: true

module Strata
  # Step is a concern that defines the interface for steps in a business process.
  # It requires implementing classes to define an execute method that takes a case
  # as an argument.
  #
  # This module is included by both StaffTask and SystemProcess to provide a
  # common interface for business process steps.
  #
  module Step
    extend ActiveSupport::Concern

    def execute(kase)
      raise NoMethodError, "#{self.class} must implement execute method"
    end
  end
end
