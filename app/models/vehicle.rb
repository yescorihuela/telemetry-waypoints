class Vehicle < ApplicationRecord
  has_many :waypoints

  validates :vehicle_identifier, presence: true
  validates :vehicle_identifier, uniqueness: true

end
