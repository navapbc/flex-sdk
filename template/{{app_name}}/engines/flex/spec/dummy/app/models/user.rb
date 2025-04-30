class User < ApplicationRecord
  has_many :tasks, as: :assignee
end