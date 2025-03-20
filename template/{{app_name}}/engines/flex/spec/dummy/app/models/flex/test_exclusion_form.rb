# require_relative "../../../../../../app/models/flex/application_form"
require File.expand_path('../../../../../../app/models/flex/application_form', __FILE__)
module Flex
  class TestExclusionForm < ApplicationForm
    attribute :business_name, :string
    attribute :business_type, :string
  end
end
