module Flex
  # Preview for the date_range form builder helper method
  class DateRangePreview < Lookbook::Preview
    layout "component_preview"

    def empty
      render template: "flex/previews/_date_range", locals: { model: TestRecord.new }
    end

    def filled
      record = TestRecord.new
      record.period = Range.new(Date.new(2023, 1, 15), Date.new(2023, 12, 31))
      render template: "flex/previews/_date_range", locals: { model: record }
    end

    def invalid
      record = TestRecord.new
      record.period_start = Date.new(2023, 12, 31)
      record.period_end = Date.new(2023, 1, 15)
      record.valid?
      render template: "flex/previews/_date_range", locals: { model: record }
    end

    def invalid_start_date
      record = TestRecord.new
      record.period = { start: "not-a-date", end: Date.new(2023, 12, 31) }
      record.valid?
      render template: "flex/previews/_date_range", locals: { model: record }
    end

    def invalid_end_date
      record = TestRecord.new
      record.period = { start: Date.new(2023, 1, 1), end: "invalid-date" }
      record.valid?
      render template: "flex/previews/_date_range", locals: { model: record }
    end

    def invalid_both_dates
      record = TestRecord.new
      record.period = { start: "bad-start", end: "bad-end" }
      record.valid?
      render template: "flex/previews/_date_range", locals: { model: record }
    end

    def invalid_date_components
      record = TestRecord.new
      # Attempting to set an invalid month (13) and day (45)
      begin
        record.period_start = Date.new(2023, 13, 45)
      rescue ArgumentError
        # Expected to fail, but we want to show how the form handles this
        record.errors.add(:period_start, :invalid_date)
      end
      record.period_end = Date.new(2023, 12, 31)
      render template: "flex/previews/_date_range", locals: { model: record }
    end

    def leap_year_edge_case
      record = TestRecord.new
      begin
        # February 29 on a non-leap year
        record.period_start = Date.new(2023, 2, 29)
      rescue ArgumentError
        record.errors.add(:period_start, :invalid_date)
      end
      # February 29 on a leap year (valid)
      record.period_end = Date.new(2024, 2, 29)
      render template: "flex/previews/_date_range", locals: { model: record }
    end
  end
end
