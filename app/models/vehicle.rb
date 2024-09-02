class Vehicle < ApplicationRecord
  has_many :waypoints
  validates :vehicle_identifier, presence: true
  validates :vehicle_identifier, uniqueness: true

  scope :latest_waypoints, -> {
    sql_query = <<-query
      SELECT
        v.id,
        latitude::decimal(18, 16),
        longitude::decimal(18, 16),
        MAX(sent_at) OVER (PARTITION BY vehicle_identifier) AS sent_at,
        vehicle_identifier
      FROM
        waypoints wp 
        INNER JOIN
          vehicles v USING(id) 
      ORDER BY
        v.id ASC
    query
    sql_query = sql_query.gsub(%r'\n', ' ').gsub(%r'\s{2,}', ' ').strip
    self.find_by_sql(sql_query)
  }
end