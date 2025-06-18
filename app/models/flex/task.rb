module Flex
  # Task is the base class for all tasks in the Flex SDK.
  # It provides common functionality for task management including
  # assignment, status tracking, and due date handling.
  #
  # Tasks are used within business processes to represent work items
  # that need to be completed, either by staff or automated systems.
  #
  # @example Creating a task subclass
  #   class MyTask < Flex::Task
  #     # Add custom attributes or behavior
  #   end
  #
  # Key features:
  # - Task assignment to users
  # - Status tracking (pending/completed)
  # - Due date management
  # - Filtering capabilities through scopes
  #
  class Task < ApplicationRecord
    attribute :description, :text
    attribute :due_on, :date
    attr_readonly :case_id
    attr_readonly :type

    attribute :assignee_id, :integer
    protected attr_writer :assignee_id

    attribute :status, :integer, default: 0
    protected attr_writer :status
    enum :status, pending: 0, completed: 1

    validates :case_id, presence: true

    default_scope -> { order(due_on: :asc) }
    scope :due_today, -> { where(due_on: Date.today) }
    scope :due_tomorrow, -> { where(due_on: Date.tomorrow) }
    scope :due_this_week, -> { where(due_on: Date.today.beginning_of_week..Date.today.end_of_week) }
    scope :overdue, -> { where("due_on < ?", Date.today) }
    scope :completed, -> { where(status: :completed) }
    scope :incomplete, -> { where.not(status: :completed) }
    scope :unassigned, -> { where(assignee_id: nil) }
    scope :with_type, ->(type) { where(type: type) }

    def self.next_unassigned
      incomplete.unassigned.first
    end

    # Creates a new non-persisted task instance associated with the given case.
    # @param kase [Flex::Case] The case to associate the task with.
    # @return [Flex::Task] The newly created task instance.
    def self.from_case(kase)
      raise ArgumentError, "`kase` must be a subclass of Flex::Case" unless kase.present? && kase.is_a?(Flex::Case)
      new(case_id: kase.id)
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

    def complete?
      status == "completed"
    end

    def incomplete?
      !complete?
    end
  end
end
