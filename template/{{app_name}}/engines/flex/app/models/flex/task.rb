module Flex
  class Task < ApplicationRecord
    # Otherwise the expected table name would be 'flex_tasks'
    # This should be able to be overridden in a subclass
    self.table_name = "tasks"

    belongs_to :assignee, optional: true, polymorphic: true

    attribute :status, :integer, default: 0
    protected attr_writer :status
    enum :status, pending: 0, completed: 1

    attribute :description, :text

    def assign(user)
      self.assignee = user
      save!
    end

    def unassign
      self.assignee = nil
      save!
    end

    def mark_completed
      self[:status] = :completed
      save!
    end
  end
end
