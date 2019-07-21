class ReadingSerializer < ActiveModel::Serializer
  attributes :thermostat_id, :tracking_number, :temperature, :humidity, :battery_charge
end