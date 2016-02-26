class School < ApplicationRecord
  has_many :users
  has_many :students
end
