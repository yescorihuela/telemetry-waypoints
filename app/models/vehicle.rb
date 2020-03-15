class Vehicle < ApplicationRecord
  has_many :waypoints
  validates :vehicle_identifier, presence: true
  validates :vehicle_identifier, uniqueness: true

  scope :latest_waypoints, ~> {
    sql_query = <<-query
      SELECT
        latitude,
        longitude,
        vehicle_identifier,
        max(sent_at) over (partition by vehicle_identifier) as latest_coordinate 
      from
        waypoints wp 
        inner join
          vehicles v using(id)
    query
    sql_query = sql_query.gsub(%r'\n', ' ').gsub(%r'\s{2,}', ' ').strip
  }


end
