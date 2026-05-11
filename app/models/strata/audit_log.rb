# frozen_string_literal: true

module Strata
  # AuditLog is the developer-facing API for writing audit history.
  #
  # The block form wraps an ActiveRecord transaction so the appended lines and
  # the caller's domain writes commit (or roll back) together. The single-line
  # form is a shortcut for one-off events that don't need a wrapper.
  #
  # @example Block form — multiple lines, atomic with caller's work
  #   Strata::AuditLog.record(actor: current_user) do |log|
  #     case_record.update!(status: :approved)
  #     log.add_line(
  #       action: "case.approved",
  #       subject: case_record,
  #       data: { previous_status: "pending" }
  #     )
  #   end
  #
  # @example Single-line form
  #   Strata::AuditLog.write!(
  #     action: "user.signed_in",
  #     actor: current_user,
  #     data: { ip: request.remote_ip }
  #   )
  #
  # @note Nested transactions: if a host already has an outer
  #   ActiveRecord::Base.transaction open, the block's transaction becomes a
  #   savepoint. ActiveRecord::Rollback raised inside the block only rolls back
  #   to that savepoint, not the outer transaction.
  #
  # @note after_commit callbacks on AuditLine fire only when the outermost
  #   transaction commits. Relevant if downstream code ships audit lines to an
  #   external sink via callbacks.
  #
  # @note Thread safety: each call to {.record} builds its own AuditLog
  #   instance, so concurrent web requests never share state. The accumulator
  #   in {#lines} is not thread-safe across threads spawned inside the block;
  #   persisted rows remain correct (Postgres serializes inserts), only the
  #   returned array can be incomplete in that case.
  class AuditLog
    # The default actor passed to {.record}, applied to every appended line that
    # doesn't pass its own `actor:` to {#add_line}.
    attr_reader :default_actor

    # The persisted lines appended during a {.record} block. Populated as
    # {#add_line} is called inside the block.
    attr_reader :lines

    # Open a wrapping DB transaction and yield an AuditLog the caller can
    # append lines to. Returns the AuditLog with {#lines} populated on success.
    # On exception, the transaction rolls back and the exception propagates.
    #
    # @param actor [Object, nil] default actor applied to every line that
    #   doesn't pass its own `actor:` to {#add_line}
    # @yieldparam log [Strata::AuditLog]
    # @return [Strata::AuditLog]
    # @raise [ArgumentError] if called without a block
    def self.record(actor: nil)
      raise ArgumentError, "Strata::AuditLog.record requires a block" unless block_given?

      log = new(default_actor: actor)
      ActiveRecord::Base.transaction { yield(log) }
      log
    end

    # Create a single audit line outside any wrapper transaction.
    #
    # @param action [String] required
    # @param actor [Object, nil] any AR record (polymorphic)
    # @param subject [Object, nil] any AR record (polymorphic)
    # @param data [Hash, nil] arbitrary jsonb payload; nil is coerced to {}
    # @return [Strata::AuditLine] the persisted line
    # @raise [ActiveRecord::RecordInvalid] if validation fails
    def self.write!(action:, actor: nil, subject: nil, data: {})
      AuditLine.create!(
        action: action,
        actor: actor,
        subject: subject,
        data: data || {}
      )
    end

    def initialize(default_actor: nil)
      @default_actor = default_actor
      @lines = []
    end

    # Append a line within the wrapping transaction.
    #
    # @param action [String] required
    # @param subject [Object, nil] any AR record (polymorphic)
    # @param data [Hash, nil] arbitrary jsonb payload; nil is coerced to {}
    # @param actor [Object, nil] per-line actor override; falls back to the
    #   default actor passed to {.record}
    # @return [Strata::AuditLine] the persisted line
    # @raise [ActiveRecord::RecordInvalid] if validation fails (also rolls back
    #   the surrounding transaction)
    def add_line(action:, subject: nil, data: {}, actor: nil)
      line = AuditLine.create!(
        action: action,
        subject: subject,
        actor: actor || @default_actor,
        data: data || {}
      )
      @lines << line
      line
    end
  end
end
