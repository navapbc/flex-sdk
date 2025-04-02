module Flex
  class ApplicationForm < ApplicationRecord
    self.abstract_class = true

    attribute :status, :integer, default: 0
    protected attr_writer :status, :integer
    enum :status, in_progress: 0, submitted: 1

    before_update :prevent_changes_if_submitted, if: :was_submitted?

    def submit_application
      self[:status] = :submitted
      save
    end

    def submitted?
      status == "submitted"
    end

    protected

    def is_submitting?
      status_was == "in_progress" && status == "submitted"
    end

    private

    def was_submitted?
      status_was == "submitted"
    end

    def prevent_changes_if_submitted
      errors.add(:base, "Cannot modify a submitted application")
      throw :abort
    end
  end
end
