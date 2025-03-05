module Flex
  class ApplicationForm < ApplicationRecord
    self.abstract_class = true

    enum status: { in_progress: 0, in_review: 1, processed: 2 }
  end
end
