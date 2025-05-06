module Flex
  class Task < ApplicationRecord
    attribute :description, :text
    attribute :due_on, :date
    attr_readonly :case_id
    attr_readonly :type

    attribute :assignee_id, :string
    protected attr_writer :assignee_id

    attribute :status, :integer, default: 0
    protected attr_writer :status
    enum :status, pending: 0, completed: 1

    validates :case_id, presence: true

    scope :where_completed, -> { where(status: :completed) }
    scope :where_not_completed, -> { where.not(status: :completed) }
    scope :where_type, ->(type) { where(type: type) }
    scope :where_due_on, ->(date) { where(due_on: date) }
    scope :where_due_on_before, ->(date) { where("due_on < ?", date) }
    scope :where_due_on_between, ->(start_date, end_date) { where(due_on: start_date..end_date) }
    scope :order_by_due_on_desc, -> { order(due_on: :desc) }
    scope :select_distinct_task_types, -> { distinct.pluck(:type) }

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
