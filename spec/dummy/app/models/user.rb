# User represents an individual who interacts with the Flex system.
#
# This model stores basic user information such as first and last name but may be extended to hold more.
class User < ApplicationRecord
  attribute :first_name, :string
  attribute :last_name, :string

  validates :first_name, presence: true
  validates :last_name, presence: true

  def full_name
    "#{first_name} #{last_name}"
  end
end
