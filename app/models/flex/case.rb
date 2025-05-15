module Flex
  class Case < ApplicationRecord
    self.abstract_class = true

    attr_accessor :application_form_id, :string

    attribute :status, :integer, default: 0
    protected attr_writer :status, :integer
    enum :status, open: 0, closed: 1

    attribute :business_process_current_step, :string

    protected attr_accessor :business_process

    after_create :execute_business_process

    def close
      self[:status] = :closed
      save
    end

    def reopen
      self[:status] = :open
      save
    end

    protected

    def execute_business_process
      business_process.execute(self)
    end
  end
end
