class User < ApplicationRecord
  attr_readonly :id, :string
  attribute :name, :string
end