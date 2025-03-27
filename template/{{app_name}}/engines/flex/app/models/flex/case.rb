module Flex
  class Case < ApplicationRecord
    self.abstract_class = true

    attribute :status, :integer, default: 0
    protected attr_writer :status, :integer
    enum :status, open: 0, closed: 1

    def close
      update(status: :closed)
    end

    def reopen
      update(status: :open)
    end
  end
end
