class Reading < ApplicationRecord
	belongs_to :thermostat
	validates_presence_of :temperature, :humidity, :battery_charge
end
