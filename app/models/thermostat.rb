# frozen_string_literal: true

class Thermostat < ApplicationRecord
  has_many :readings, dependent: :destroy
  validates_presence_of :household_token, :location
end
