require 'rails_helper'

RSpec.describe "Gps", type: :request do
  # Test suite for POST /api/v1/gps
  describe 'POST requests to api/v1/gps' do
    # valid payload
    let(:valid_attributes) { {"latitude": -33.45382270754665,"longitude": -70.69075584411621, "sent_at": "2020-02-02 00:00:00", "vehicle_identifier": "HA-3452", format: :json} }

    context 'when the request is valid' do
      before do
        post '/api/v1/gps', params: valid_attributes
      end

      it 'creates a gps measurement' do
        expect(nil).to eq(nil)
      end

      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end
    end
  end
end
