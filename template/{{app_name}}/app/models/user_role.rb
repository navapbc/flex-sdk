class UserRole < ApplicationRecord
  # == Enums ================================================================
  # See `technical-foundation.md#enums` for important note about enums.
  enum :role, { applicant: 0, employer: 1 }, default: :applicant, validate: true

  # == Relationships ========================================================
  belongs_to :user
end
