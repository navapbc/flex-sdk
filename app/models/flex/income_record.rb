module Flex
  # IncomeRecord is a model for storing income records with different period types.
  # It uses a factory pattern to create specialized subclasses for different period types
  # like YearQuarter or DateRange.
  #
  # @example Creating a quarterly wage record
  #   QuarterlyWage = IncomeRecord[Flex::YearQuarter]
  #   record = QuarterlyWage.new(
  #     person_id: "123",
  #     amount: Flex::Money.new(5000),
  #     period: Flex::YearQuarter.new(2023, 2)
  #   )
  #
  # @example Creating an annual salary record
  #   AnnualSalary = IncomeRecord[Range]
  #   record = AnnualSalary.new(
  #     person_id: "456",
  #     amount: Flex::Money.new(75000_00),
  #     period: Date.new(2023, 1, 1)..Date.new(2023, 12, 31)
  #   )
  #
  class IncomeRecord < ApplicationRecord
    include Flex::Attributes

    self.table_name = "income_records"

    attribute :person_id, :string
    money_attribute :amount

    def self.[](period_type)
      Class.new(self) do
        if period_type == :year_quarter || period_type == Flex::YearQuarter
          year_quarter_attribute :period

          define_singleton_method :period_type do
            :year_quarter
          end

        elsif period_type == :date_range || period_type == Range
          date_range_attribute :period

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
