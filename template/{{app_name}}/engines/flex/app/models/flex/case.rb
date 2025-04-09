module Flex
  class Case < ApplicationRecord
    self.abstract_class = true

    attribute :status, :integer, default: 0
    protected attr_writer :status, :integer
    enum :status, open: 0, closed: 1

    attribute :business_process_current_step, :string

    protected attr_accessor :business_process

    def close
      self[:status] = :closed
      save
    end
    
    def reopen
      self[:status] = :open
      save
    end
  end
end
