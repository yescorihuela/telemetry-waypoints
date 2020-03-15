class Api::V1::GpsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    render json: {:message => 'API is working...'}, status: :ok
  end

  def create_waypoint
    GpsMeasurementsWorker.set(queue: :gps_measurements).perform_async(set_waypoint)
    render json: nil, status: :no_content
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
