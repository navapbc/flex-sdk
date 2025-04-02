module Flex
  class Case < ApplicationRecord
    self.abstract_class = true

    attribute :status, :integer, default: 0
    protected attr_writer :status, :integer
    enum :status, open: 0, closed: 1

    attribute readonly :business_process
    attribute :business_process_current_step, :string

    readonly attribute :passport_id, :string, default: SecureRandom.uuid

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
