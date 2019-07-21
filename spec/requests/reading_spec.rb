# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'thermostat API', type: :request do
  let!(:thermostats) { create_list(:thermostat, 10) }
  let!(:thermostat) { thermostats.first }
  let!(:thermostat_id) { thermostat&.id }
  let!(:thermostat_cache) { RedisHandler.set(thermostat_id, 'thermostat_id' => thermostat_id, 'household_token' => thermostat&.household_token, 'location' => thermostat&.location) }
  # Test suite for POST /thermostats/:thermostat_id/readings
  describe 'POST /api/thermostats/:thermostat_id/readings' do
    let(:valid_attributes) { { 'thermostat_id' => thermostat_id, 'temperature' => 25.00, 'humidity' => 19.00, 'battery_charge' => 80.00 } }
    before do
      post "/api/thermostats/#{thermostat_id}/readings/", params: valid_attributes, headers: { 'auth_token' => thermostat&.household_token }
    end
    let!(:thermostats_data) { RedisHandler.get(thermostat_id) }

    it 'stats in cache' do
      expect(json['tracking_number']).to eq(1)
      expect(thermostats_data['tracking_number']).to eq(1)
    end

    it 'current reading in cache' do
      expect(RedisHandler.get("reading_#{thermostat_id}_1").is_a?(Hash)).to be_truthy
    end

    it 'job should be enqued' do
      expect(ThermostatReadingWorker).to be_processed_in :default
      expect(ThermostatReadingWorker).to have_enqueued_sidekiq_job("reading_#{thermostat_id}_1")
    end

    it 'stats data having all keys' do
      keys = %w[thermostat_id tracking_number average_temperature average_humidity average_battery_charge maximum_temperature maximum_humidity maximum_battery_charge minimum_temperature minimum_humidity minimum_battery_charge location household_token]
      expect(keys.size).to eq(thermostats_data.size)
      expect(keys.all? { |key| !!thermostats_data[key] }).to eq(true)
    end

    it 'stats with updated values' do
      expect(thermostats_data['average_temperature']).to eq(25)
      expect(thermostats_data['average_humidity']).to eq(19)
      expect(thermostats_data['average_battery_charge']).to eq(80)
      expect(thermostats_data['maximum_temperature']).to eq(25)
      expect(thermostats_data['maximum_humidity']).to eq(19)
      expect(thermostats_data['maximum_battery_charge']).to eq(80)
      expect(thermostats_data['minimum_temperature']).to eq(25)
      expect(thermostats_data['minimum_humidity']).to eq(19)
      expect(thermostats_data['minimum_battery_charge']).to eq(80)
    end

    it 'auth token missing' do
      post "/api/thermostats/#{thermostat_id}/readings/", params: valid_attributes
      expect(json).to eq('Authentication token is missing')
    end
  end

  describe 'GET /api/thermostats/:thermostat_id/readings/:tracking_number' do
    let!(:tracking_number) { 1 }
    let!(:thermostat_cache) { RedisHandler.set("reading_#{thermostat_id}_1", 'thermostat_id' => thermostat_id, 'tracking_number' => tracking_number, 'temperature' => 25.00, 'humidity' => 19.00, 'battery_charge' => 80.00) }
    let!(:thermostats_data) { RedisHandler.get(thermostat_id) }
    context 'get readings' do
      it 'fetch from cache' do
        get "/api/thermostats/#{thermostat_id}/readings/#{tracking_number}", params: {}, headers: { 'auth_token' => thermostats_data['household_token'] }
        expect(ThermostatReadingWorker).not_to have_enqueued_sidekiq_job("reading_#{thermostat_id}_1")
        expect(Reading.last).to eq(nil)
        expect(json).not_to be_empty
        expect(json['thermostat_id']).to eq(thermostat_id)
        expect(json['tracking_number']).to eq(1)
      end

      it 'fetch from DB' do
        ThermostatReadingWorker.new.perform("reading_#{thermostat_id}_1")
        get "/api/thermostats/#{thermostat_id}/readings/#{tracking_number}", params: {}, headers: { 'auth_token' => thermostats_data['household_token'] }
        expect(RedisHandler.get("reading_#{thermostat_id}_1")).to eq nil
        expect(Reading.last).to be_truthy
        expect(json).not_to be_empty
        expect(json['thermostat_id']).to eq(thermostat_id)
        expect(json['tracking_number']).to eq(1)
      end

      it 'returns status code 200' do
        get "/api/thermostats/#{thermostat_id}/readings/#{tracking_number}", params: {}, headers: { 'auth_token' => thermostats_data['household_token'] }
        expect(response).to have_http_status(200)
      end
    end
  end
end
