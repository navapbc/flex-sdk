class PassportApplicationForm < Flex::ApplicationForm
  include Flex::Attributes

  flex_attribute :name, :name
  flex_attribute :date_of_birth, :memorable_date
  flex_attribute :supporting_documents, :document

  def has_all_necessary_fields?
    !name_first.nil? && !name_last.nil? && !date_of_birth.nil?
  end

  def submit_application
    has_all_necessary_fields? ? super : false
  end
end
