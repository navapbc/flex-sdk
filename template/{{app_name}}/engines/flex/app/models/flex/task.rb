module Flex
  class Task < ApplicationRecord
    attribute :assignee_id, :string
    attribute :case_id, :string, null: false
    attribute :description, :text
    
    attribute :status, :integer, default: 0
    protected attr_writer :status
    enum :status, pending: 0, completed: 1
    
    validates :case_id, presence: true

    def assign(user_id)
      self.assignee_id = user_id
      save!
    end

    def unassign
      self.assignee_id = nil
      save!
    end

    def mark_completed
      self[:status] = :completed
      save!
    end
  end
end
