class GpsMeasurementsWorker
  include Sidekiq::Worker
  
  sidekiq_options queue: :gps_measurements, retry: false, backtrace: false

  def perform(waypoint)
    vehicle = OpenStruct.new(:id => nil, **waypoint.transform_keys(&:to_sym))
    vehicle_identifier = vehicle.vehicle_identifier
    
    begin
      vehicle.id = Services::LastWaypointsVehicle.get_or_create_vehicle_in_cache(vehicle_identifier)[:id]
    rescue
      vehicle.id = nil
    end

    if vehicle.id.nil?
      vehicle = Vehicle.find_by(vehicle_identifier: vehicle_identifier)
      if vehicle.nil?
        vehicle = Vehicle.new(vehicle_identifier: vehicle_identifier)
        if vehicle.valid?
          vehicle.save!
        end
      end
      vehicle = OpenStruct.new(:id => vehicle.id, **waypoint.transform_keys(&:to_sym))
    end
    Services::LastWaypointsVehicle.get_or_create_vehicle_in_cache(vehicle_identifier, vehicle)
    create_waypoint(vehicle.id, waypoint)
  end


  def create_waypoint(vehicle_id, waypoint)
    new_waypoint = OpenStruct.new(waypoint)
    new_waypoint.delete_field('vehicle_identifier')
    new_waypoint[:vehicle_id] = vehicle_id 

    begin
      Waypoint.create!(new_waypoint.to_h)
    rescue => exception
      Rails.logger.warning exception
    end
  end


end
