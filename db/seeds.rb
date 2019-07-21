# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
1.upto(10) do |thermostat|
  token = SecureRandom.base64(10)
  location = Faker::Address.street_address
  t = Thermostat.find_or_initialize_by(id: thermostat) 
  t.household_token = token
  t.location = location
  t.save!
end
