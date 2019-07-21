# frozen_string_literal: true

FactoryBot.define do
  factory :reading do
    tracking_number { Faker::Numbers.digit }
    temperature { Faker::Numbers.decimal }
    humidity { Faker::Numbers.decimal }
    battery_charge { Faker::Numbers.decimal }
  end
end
