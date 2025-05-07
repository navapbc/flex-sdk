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

    default_scope -> { order(due_on: :desc) }
    scope :due_today, -> { where(due_on: Date.today) }
    scope :due_tomorrow, -> { where(due_on: Date.tomorrow) }
    scope :due_this_week, -> { where(due_on: Date.today.beginning_of_week..Date.today.end_of_week) }
    scope :overdue, -> { where("due_on < ?", Date.today) }
    scope :completed, -> { where(status: :completed) }
    scope :incomplete, -> { where.not(status: :completed) }
    scope :with_type, ->(type) { where(type: type) }

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
