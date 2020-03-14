require 'rails_helper'

RSpec.describe Waypoint, type: :model do
  describe 'validations' do

    subject { Vehicle.new(vehicle_identifier: 'HA-3452') }
    subject { Waypoint.new(latitude: -33.45382270754665, longitude: -70.69075584411621, sent_at: Time.now())}
    
    it { should belong_to(:vehicle) }

    it { should validate_presence_of(:latitude) }
    it { should validate_presence_of(:longitude) }
    it { should validate_presence_of(:sent_at) }

  end
end
