class User < ApplicationRecord
  attr_readonly :id, :string, default: -> { SecureRandom.uuid }
  attribute :first_name, :string
  attribute :last_name, :string

  validates :first_name, presence: true
  validates :last_name, presence: true
end