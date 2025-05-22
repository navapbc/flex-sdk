module Flex
  class User < ApplicationRecord
    attribute :first_name, :string
    attribute :last_name, :string

    validates :first_name, presence: true
    validates :last_name, presence: true

    def full_name
      "#{first_name} #{last_name}"
    end
  end
end
