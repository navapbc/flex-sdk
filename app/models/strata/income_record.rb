module Strata
  # IncomeRecord is a model for storing income records with different period types.
  # It uses a factory pattern to create specialized subclasses for different period types
  # like YearQuarter or DateRange.
  #
  # @example Creating a quarterly wage record
  #   QuarterlyWage = IncomeRecord[Strata::YearQuarter]
  #   record = QuarterlyWage.new(
  #     person_id: "123",
  #     amount: Strata::Money.new(5000),
  #     period: Strata::YearQuarter.new(2023, 2)
  #   )
  #
  # @example Creating an annual salary record
  #   AnnualSalary = IncomeRecord[Range]
  #   record = AnnualSalary.new(
  #     person_id: "456",
  #     amount: Strata::Money.new(75000_00),
  #     period: Date.new(2023, 1, 1)..Date.new(2023, 12, 31)
  #   )
  #
  class IncomeRecord < ApplicationRecord
    include Strata::Attributes

    self.abstract_class = true

    attribute :person_id, :uuid
    strata_attribute :amount, :money

    def self.[](period_type)
      Class.new(self) do
        if period_type == :year_quarter || period_type == Strata::YearQuarter
          strata_attribute :period, :year_quarter

          define_singleton_method :period_type do
            :year_quarter
          end

        elsif period_type == :date_range || period_type == Range
          strata_attribute :period, :us_date, range: true

          define_singleton_method :period_type do
            :date_range
          end

        else
          raise ArgumentError, "Unsupported period type: #{period_type}"
        end
      end
    end

    def self.period_type
      nil
    end
  end
end
