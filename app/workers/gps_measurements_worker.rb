class GpsMeasurementsWorker
  include Sidekiq::Worker
  sidekiq_options queue: :gps_measurements, retry: false, backtrace: false

  def perform(waypoint)
    latitude = waypoint['latitude']
    longitude = waypoint['longitude']
    sent_at = waypoint['sent_at']
    vehicle_identifier = waypoint['vehicle_identifier']

    vehicle = OpenStruct.new(:id => nil)
    vehicle.id = get_or_create_vehicle_in_cache(vehicle_identifier)

    if vehicle.id.nil?
      vehicle = Vehicle.find_by(vehicle_identifier: vehicle_identifier)
      if vehicle.nil?
        vehicle = Vehicle.new(vehicle_identifier: vehicle_identifier)
        if vehicle.valid?
          vehicle.save!
          get_or_create_vehicle_in_cache(vehicle_identifier, vehicle.id)
        end
      end
      get_or_create_vehicle_in_cache(vehicle_identifier, vehicle.id)
    end
    create_waypoint(vehicle.id, waypoint)
  end


  def create_waypoint(vehicle_id, waypoint)
    new_waypoint = OpenStruct.new(waypoint)
    new_waypoint[:vehicle_id] = vehicle_id
    new_waypoint.delete_field('vehicle_identifier')
    begin
      Waypoint.create!(new_waypoint.to_h)
    rescue => exception
      # TO-DO
      # Introduce logging and control exception here
    end
  end

  def get_or_create_vehicle_in_cache(vehicle_license_plate, vehicle_id = nil)
    if vehicle_id.nil?
      Rails.cache.read(vehicle_license_plate)
    else
      Rails.cache.write(vehicle_license_plate, vehicle_id)
    end
  end
end
