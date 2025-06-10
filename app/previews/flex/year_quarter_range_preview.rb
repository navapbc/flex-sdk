class Flex::YearQuarterRangePreview < Lookbook::Preview
  layout "component_preview"

  def empty
    render template: "flex/previews/year_quarter_range", locals: { model: TestRecord.new }
  end

  def filled
    start_yq = Flex::YearQuarter.new(2023, 1)
    end_yq = Flex::YearQuarter.new(2024, 4)
    model = TestRecord.new(base_period: start_yq..end_yq)
    render template: "flex/previews/year_quarter_range", locals: { model: model }
  end

  def invalid
    model = TestRecord.new
    model.base_period_start = Flex::YearQuarter.new(2024, 4)
    model.base_period_end = Flex::YearQuarter.new(2023, 1)
    model.valid?
    render template: "flex/previews/year_quarter_range", locals: { model: model }
  end
end
