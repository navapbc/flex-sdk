module Flex
  class Task < ApplicationRecord
    attribute :description, :text
    attribute :due_on, :date
    attribute :assignee_id, :string
    attribute :case_id, :string
    readonly attribute :type, :string

    attribute :status, :integer, default: 0
    protected attr_writer :status
    enum :status, pending: 0, completed: 1

    validates :case_id, presence: true

    scope :filter_by_due_on, ->(date) { where(due_on: date) }
    scope :filter_by_due_on_range, ->(start_date, end_date) { where(due_on: start_date..end_date) }
    scope :filter_by_due_on_before, ->(date) { where("due_on < ?", date) }
    scope :order_by_due_on_desc, -> { order(due_on: :desc) }
    scope :distinct_task_types, -> { select(:type).distinct }

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
