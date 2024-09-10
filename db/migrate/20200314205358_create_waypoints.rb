class CreateWaypoints < ActiveRecord::Migration[5.2]
  def change
    create_table :waypoints do |t|
      t.decimal :latitude, precision: 17, scale: 14
      t.decimal :longitude, precision: 17, scale: 14
      t.datetime :sent_at
      t.references :vehicle, foreign_key: true

      t.timestamps
    end
  end
end
