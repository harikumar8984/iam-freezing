# frozen_string_literal: true

# Handling redis utilies functions
# Test enviornment using MockRedis
if Rails.env.test?
  REDIS = Redis::Namespace.new(:thermostat_space, redis: MockRedis.new)
else
  REDIS = Redis::Namespace.new(:thermostat_space, redis: Redis.new(Rails.application.config_for(:redis)))
end

class RedisHandler
  # Get value from redis cache
  def self.get(token)
    cache = REDIS.get(token)
    JsonFormatter.parse(cache) if cache.present?
  rescue StandardError => e
    raise ExceptionHandler::InvalidToken, e.message
  end

  # Set one key-value pair to cache
  def self.set(key, value)
    REDIS.set(key, value)
  rescue StandardError => e
    raise ExceptionHandler::InvalidToken, e.message
  end

  # Delete key from cache
  def self.del(key)
    REDIS.del(key)
  rescue StandardError => e
    raise ExceptionHandler::InvalidToken, e.message
  end
end
