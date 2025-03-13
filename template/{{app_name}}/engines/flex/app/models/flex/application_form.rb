module Flex
  class ApplicationForm < ApplicationRecord
    self.abstract_class = true
    
    attribute :status, :integer, default: 0
    enum :status, in_progress: 0, submitted: 1
  end
end
