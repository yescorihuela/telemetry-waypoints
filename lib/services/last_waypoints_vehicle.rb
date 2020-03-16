module Services
  class LastWaypointsVehicle
    def self.get_or_create_vehicle_in_cache(vehicle_identifier, vehicle_obj)
      if vehicle_identifier.nil?
        Rails.cache.read(vehicle_identifier)
      else
        Rails.cache.write(vehicle_identifier, vehicle_obj)
      end
    end

    def self.get_vehicles_latest_waypoints()
      # TO-DO refactor for others caching providers
      begin
        latest_waypoints = []
        current_cached_data = Rails.cache.redis.keys.select{|s| s =~ /#{Rails.cache.options[:namespace]}/ }
        current_vehicles = current_cached_data.map{|v| v.split(':')[1]}
        latest_cached_waypoints = Rails.cache.read_multi(*current_vehicles)

        current_vehicles.each do |vehicle|
          latest_waypoints.append(latest_cached_waypoints[vehicle].to_h)
        end
        latest_waypoints
      rescue => e
        Rails.logger.error e
        []
      end
    end
  end
end