# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'thermostat API', type: :request do
  # initialize test data
  let!(:thermostats) { create_list(:thermostat, 10) }
  let!(:thermostat) { thermostats.first }
  let!(:thermostat_id) { thermostat&.id }
  let!(:redis_thermostat) { RedisHandler.set(thermostat_id, 'thermostat_id' => thermostat_id, 'household_token' => thermostat&.household_token, 'location' => thermostat&.location) }

  describe 'GET /api/thermostats/:id/' do
    # before(:all) do
    #   RedisHandler.del(thermostat_id)
    # end
    context 'stats fetch from cache' do
      let(:valid_attributes) { { 'thermostat_id' => thermostat_id, 'temperature' => 25.00, 'humidity' => 19.00, 'battery_charge' => 80.00 } }
      let(:valid_attributes_1) { { 'thermostat_id' => thermostat_id, 'temperature' => 15.00, 'humidity' => 11.00, 'battery_charge' => 60.00 } }
      it 'returns the thermostat stats' do
        post "/api/thermostats/#{thermostat_id}/readings/", params: valid_attributes, headers: { 'auth_token' => thermostat&.household_token }
        get "/api/thermostats/#{thermostat_id}", headers: { 'auth_token' => thermostat&.household_token }
        expect(json).not_to be_empty
        expect(json['thermostat_id']).to eq(thermostat_id)
        expect(json['household_token']).to eq(thermostat&.household_token)
        expect(json['tracking_number']).to eq(1)
      end
      it 'stats data accuracy' do
        post "/api/thermostats/#{thermostat_id}/readings/", params: valid_attributes, headers: { 'auth_token' => thermostat&.household_token }
        post "/api/thermostats/#{thermostat_id}/readings/", params: valid_attributes_1, headers: { 'auth_token' => thermostat&.household_token }
        get "/api/thermostats/#{thermostat_id}", headers: { 'auth_token' => thermostat&.household_token }
        expect(json['average_temperature']).to eq(20)
        expect(json['average_humidity']).to eq(15)
        expect(json['average_battery_charge']).to eq(70)
        expect(json['maximum_temperature']).to eq(25)
        expect(json['maximum_humidity']).to eq(19)
        expect(json['maximum_battery_charge']).to eq(80)
        expect(json['minimum_temperature']).to eq(15)
        expect(json['minimum_humidity']).to eq(11)
        expect(json['minimum_battery_charge']).to eq(60)
      end

      it 'check tracking number' do
        post "/api/thermostats/#{thermostat_id}/readings/", params: valid_attributes_1, headers: { 'auth_token' => thermostat&.household_token }
        post "/api/thermostats/#{thermostat_id}/readings/",  params: valid_attributes_1, headers: { 'auth_token' => thermostat&.household_token }
        post "/api/thermostats/#{thermostat_id}/readings/",  params: valid_attributes_1, headers: { 'auth_token' => thermostat&.household_token }
        expect(json['tracking_number']).to eq(3)
      end
    end
  end
end
