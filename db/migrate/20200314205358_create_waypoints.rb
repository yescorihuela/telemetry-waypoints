class CreateWaypoints < ActiveRecord::Migration[5.2]
  def change
    create_table :waypoints do |t|
      t.decimal :latitude, precision: 3, scale: 16
      t.decimal :longitude, precision: 3, scale: 16
      t.datetime :send_at
      t.references :vehicle, foreign_key: true

      t.timestamps
    end
  end
end