module Flex
  class ApplicationForm < ApplicationRecord
    self.abstract_class = true

    attribute :status, :integer, default: 0
    enum :status, in_progress: 0, submitted: 1

    validate :prevent_changes_if_submitted, on: :update

    def submit_form
      update(status: :submitted)
    end

    private

    def prevent_changes_if_submitted
      if status_was == "submitted"
        errors.add(:base, "Cannot modify a submitted application")
      end
    end
  end
end
