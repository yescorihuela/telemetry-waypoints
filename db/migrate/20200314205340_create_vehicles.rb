class CreateVehicles < ActiveRecord::Migration[5.2]
  def change
    create_table :vehicles do |t|
      t.string :vehicle_identifier, unique: true

      t.timestamps
    end
  end
end
