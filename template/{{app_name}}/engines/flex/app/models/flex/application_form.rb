module Flex
  class ApplicationForm < ApplicationRecord
    self.abstract_class = true

    enum :status, in_progress: 0, submitted: 1
  end
end
