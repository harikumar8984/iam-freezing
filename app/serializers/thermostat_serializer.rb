class ThermostatSerializer < ActiveModel::Serializer
  attributes :id, :household_token, :location
end
