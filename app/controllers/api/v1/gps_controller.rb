class Api::V1::GpsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    render json: {:message => 'API is working...'}, status: :ok
  end

  def create_waypoint
    render json: params[:gp], status: :ok
  end

end
