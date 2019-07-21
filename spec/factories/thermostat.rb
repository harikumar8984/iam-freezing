# frozen_string_literal: true

FactoryBot.define do
  factory :thermostat do
    household_token { SecureRandom.base64(10) }
    location { Faker::Address.street_address }
  end
end
