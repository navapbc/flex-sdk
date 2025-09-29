module Strata
  # Preview for the date_range form builder helper method
  class DateRangePreview < Lookbook::Preview
    layout "component_preview"

    def empty
      render template: "strata/previews/_date_range", locals: { model: TestRecord.new }
    end

    def filled
      record = TestRecord.new
      record.period = Range.new(Date.new(2023, 1, 15), Date.new(2023, 12, 31))
      render template: "strata/previews/_date_range", locals: { model: record }
    end

    def invalid
      record = TestRecord.new
      record.period_start = Date.new(2023, 12, 31)
      record.period_end = Date.new(2023, 1, 15)
      record.valid?
      render template: "strata/previews/_date_range", locals: { model: record }
    end

    def invalid_start_date
      record = TestRecord.new
      record.period_start = "02/45/2023"
      record.period_end = "12/31/2023"
      record.valid?
      render template: "strata/previews/_date_range", locals: { model: record }
    end

    def invalid_end_date
      record = TestRecord.new
      record.period_start = "01/02/2023"
      record.period_end = "not-a-date"
      record.valid?
      render template: "strata/previews/_date_range", locals: { model: record }
    end
  end
end
