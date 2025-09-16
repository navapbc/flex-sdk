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
    after_update :publish_status_changed_event, if: :saved_change_to_status?

    attribute :description, :text
    attribute :due_on, :date
    attr_readonly :type, :case_id, :case_type, :id

    attribute :assignee_id, :uuid
    protected attr_writer :assignee_id

    attribute :status, :integer, default: 0
    enum :status, pending: 0, completed: 1

    belongs_to :case, polymorphic: true
    validates :case, presence: true

    default_scope -> { preload(:case).order(due_on: :asc) }
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

    def self.assign_next_task_to(user_id)
      transaction do
        task = next_unassigned
        return nil if !task

        task.assign(user_id)
        task
      end
    end

    def assign(user_id)
      self[:assignee_id] = user_id
      save!
    end

    def unassign
      self[:assignee_id] = nil
      save!
    end

    private

    def publish_status_changed_event
      Flex::EventManager.publish("#{self.class.name}#{status.capitalize}", { task_id: id, case_id: case_id })
    end
  end
end
