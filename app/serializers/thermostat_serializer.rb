# frozen_string_literal: true

class ThermostatSerializer < ActiveModel::Serializer
  attributes :id, :household_token, :location
end
