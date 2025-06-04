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
  end
end
