# frozen_string_literal: true

# Thermostat ReadingComtroller
class Api::V1::ReadingsController < ApplicationController
  include ReadingConcern

  def create
    if valid_params?(params)
      RedisHandler.set(stats_key, sanitized_params)
      RedisHandler.set(reading_key, readings_params)
      ThermostatReadingWorker.perform_async(reading_key)
      render json: { tracking_number: readings_params['tracking_number'] }, status: :created
    else
      render json: { message: I18n.t(:field_missing) }, status: :bad_request
    end
  end

  def show
    if valid_params?(params, true)
      reading_data = RedisHandler.get(reading_key)
      if reading_data.present?
        render json: reading_data, status: :ok
      else
        render json: Reading.find_by_thermostat_id_and_tracking_number!(params[:thermostat_id], params[:tracking_number]), status: :ok
      end
    else
      render json: { message: I18n.t(:field_missing) }, status: :bad_request
    end
  end

  def readings_params
    params.permit(:temperature, :humidity, :battery_charge, :thermostat_id).merge(tracking_number: tracking_number)
  end
end
