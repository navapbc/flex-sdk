require 'test_helper'

module Flex
  class ApplicationFormAcceptanceTest < ActiveSupport::TestCase
    fixtures :all

    def setup
      @service = BusinessExclusionFormService.new
    end

    test 'submitting an application form' do
      @service.submit_form(1)
      assert_equal ApplicationForm.statuses[:submitted], BusinessExclusionForm.find(1).status
    end

  end
end
