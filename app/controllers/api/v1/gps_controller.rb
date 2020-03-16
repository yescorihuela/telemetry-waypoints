class Api::V1::GpsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    render json: {:message => 'API is working...'}, status: :ok
  end

  def create_waypoint
    GpsMeasurementsWorker.set(queue: :gps_measurements).perform_async(set_waypoint)
    render json: nil, status: :no_content
  end

  def latest_waypoints
    begin
      cache_waypoints = Services::LastWaypointsVehicle.get_vehicles_latest_waypoints
      if cache_waypoints.empty?
        @latest_waypoints = Vehicle.latest_waypoints
      else
        @latest_waypoints = cache_waypoints
      end
      render json: @latest_waypoints, status: :ok 
    rescue => e
      render json: e, status: 500 
    end
  end

  private 
  def set_waypoint
    {
      :latitude => params[:latitude],
      :longitude => params[:longitude],
      :sent_at => params[:sent_at],
      :vehicle_identifier => params[:vehicle_identifier]
    }
  end

end
