class PassportApplicationForm < Flex::ApplicationForm
  before_create :create_passport_case, unless: -> { has_case_id? }

  attribute :first_name, :string
  attribute :last_name, :string

  attribute :date_of_birth_year, :integer
  attribute :date_of_birth_month, :integer
  attribute :date_of_birth_day, :integer
  composed_of :date_of_birth, class_name: "Date",
      mapping: {
        date_of_birth_year: :year,
        date_of_birth_month: :month,
        date_of_birth_day: :day
      },
      allow_nil: true,
      converter: Proc.new { |value|
        Date.new(value[:year], value[:month], value[:day]) if value.is_a?(Hash)
      }

  attribute :case_id, :integer
  private def case_id=(value)
    self[:case_id] = value
  end

  def has_all_necessary_fields?
    !first_name.nil? && !last_name.nil? && !date_of_birth.nil?
  end

  def submit_application
    has_all_necessary_fields? ? super : false
  end

  protected

  def event_payload
    parent_payload = super
    parent_payload.merge({ case_id: case_id })
  end

  private

  def has_case_id?
    !case_id.nil?
  end

  def create_passport_case
    kase = PassportCase.create
    self.case_id = kase.id
  end
end
