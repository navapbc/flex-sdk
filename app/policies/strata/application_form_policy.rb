# frozen_string_literal: true

module Strata
  # Common policy for application forms
  #
  # @note All actions require a logged-in user
  # @note Submitted applications cannot be modified
  #
  module ApplicationFormPolicy
    def index?
      user # any logged-in user
    end

    def show?
      owner?
    end

    def create?
      user # any logged-in user
    end

    def update?
      owner? && record.in_progress?
    end

    def review?
      owner? && record.in_progress?
    end

    def destroy?
      owner? && record.in_progress?
    end

    def submit?
      owner? && !record.submitted?
    end

    # rubocop:disable Style/Documentation
    class Scope < ::ApplicationPolicy::Scope
      def resolve
        scope.where(user_id: user.id)
      end
    end

    private

    def owner?
      record.user_id == user.id
    end
  end
end
