module Flex
  class Task < ApplicationRecord
    attribute :description, :text
    readonly attribute :type, :string

    attribute :assignee_id, :string
    protected attr_writer :assignee_id

    attribute :case_id, :string
    protected attr_writer :case_id

    attribute :status, :integer, default: 0
    protected attr_writer :status
    enum :status, pending: 0, completed: 1

    validates :case_id, presence: true

    def set_case(case_id)
      self[:case_id] = case_id
      save!
    end

    def assign(user_id)
      self[:assignee_id] = user_id
      save!
    end

    def unassign
      self[:assignee_id] = nil
      save!
    end

    def mark_completed
      self[:status] = :completed
      save!
    end

    def mark_pending
      self[:status] = :pending
      save!
    end
  end
end
