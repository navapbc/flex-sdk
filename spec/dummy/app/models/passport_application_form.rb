class PassportApplicationForm < Flex::ApplicationForm
  include Flex::Attributes

  attribute :first_name, :string
  attribute :last_name, :string

  flex_attribute :date_of_birth, :memorable_date

  def has_all_necessary_fields?
    !first_name.nil? && !last_name.nil? && !date_of_birth.nil?
  end

  def submit_application
    has_all_necessary_fields? ? super : false
  end

  def full_name
    "#{first_name} #{last_name}"
  end
end
