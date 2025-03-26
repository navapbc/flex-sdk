module Flex
  class ApplicationForm < ApplicationRecord
    self.abstract_class = true

    attribute :status, :integer, default: 0
    protected attr_writer :status, :integer
    enum :status, in_progress: 0, submitted: 1

    before_update :prevent_changes_if_submitted

    def submit_application
      self[:status] = :submitted
      save
    end

    private

    def prevent_changes_if_submitted
      if status_was == "submitted"
        errors.add(:base, "Cannot modify a submitted application")
        throw :abort
      end
    end
  end
end
