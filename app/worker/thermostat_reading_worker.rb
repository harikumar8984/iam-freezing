# frozen_string_literal: true

class ThermostatReadingWorker
  include Sidekiq::Worker

  def perform(key)
    Reading.create!(RedisHandler.get(key))
    remove_key(key)
  end

  def remove_key(key)
    RedisHandler.del(key)
  end
end
