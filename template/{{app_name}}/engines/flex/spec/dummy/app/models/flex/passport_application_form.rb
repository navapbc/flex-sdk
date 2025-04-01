require_relative "../../../../../app/models/flex/application_form"
module Flex
  class PassportApplicationForm < ApplicationForm
    attribute :first_name, :string
    attribute :last_name, :string
    attribute :date_of_birth, :date
  end
end
