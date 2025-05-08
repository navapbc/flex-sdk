class PassportApplicationForm < Flex::ApplicationForm
  include Flex::Attributes

  before_create :create_passport_case, unless: -> { has_case_id? }

  attribute :first_name, :string
  attribute :last_name, :string

  flex_attribute :date_of_birth, :memorable_date

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
