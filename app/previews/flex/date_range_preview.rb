module Flex
  # Preview for the date_range form builder helper method
  class DateRangePreview < ViewComponent::Preview
    layout "component_preview"

    def empty
      render_with_template(locals: { record: test_record })
    end

    def filled
      record = test_record
      record.date_range = Range.new(Date.new(2023, 1, 1), Date.new(2023, 12, 31))
      render_with_template(locals: { record: record })
    end

    def invalid
      record = test_record
      record.date_range_start = Date.new(2023, 12, 31)
      record.date_range_end = Date.new(2023, 1, 1)
      record.valid?
      render_with_template(locals: { record: record })
    end

    private

    def test_record
      TestRecord.new
    end
  end
end
