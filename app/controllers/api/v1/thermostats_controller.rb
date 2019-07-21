# frozen_string_literal: true

# Thermostat Controller
class Api::V1::ThermostatsController < ApplicationController
  def show
    @thermostat_stats = RedisHandler.get(params[:id])
    render json: @thermostat_stats, status: :ok
  end
end
