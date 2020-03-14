require 'rails_helper'

RSpec.describe Vehicle, type: :model do
  describe 'validations' do 
    subject{ Vehicle.new(vehicle_identifier: 'HA-3452') }

    it { should validate_presence_of(:vehicle_identifier) }
    it { should validate_uniqueness_of(:vehicle_identifier) }
  end
end
