module Flex
  class BusinessExclusionFormService < ApplicationFormService
    def initialize(repository: BusinessExclusionFormRepository.new)
      @repository = repository
    end
  end
end