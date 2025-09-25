class PassportApplicationForm < Flex::ApplicationForm
  include Strata::Attributes

  flex_attribute :name, :name
  flex_attribute :date_of_birth, :memorable_date

  def has_all_necessary_fields?
    !name_first.nil? && !name_last.nil? && !date_of_birth.nil?
  end

  def submit_application
    has_all_necessary_fields? ? super : false
  end
end
