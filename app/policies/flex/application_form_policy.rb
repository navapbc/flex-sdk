module Flex
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
      owning_user?
    end

    def create?
      user # any logged-in user
    end

    def update?
      owning_user? && record.in_progress?
    end

    def review?
      owning_user? && record.in_progress?
    end

    def destroy?
      owning_user? && record.in_progress?
    end

    def submit?
      owning_user? && !record.submitted?
    end

    class Scope < ::ApplicationPolicy::Scope
      def resolve
        scope.where(user_id: user.id)
      end
    end

    private

    def owning_user?
      record.user_id == user.id
    end
  end
end
