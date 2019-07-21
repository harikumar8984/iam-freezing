# frozen_string_literal: true

# Handling Authentication
module AuthenticationConcern
  extend ActiveSupport::Concern

  def token?(options = {})
    id = options[:thermostat_id] || options[:id]
    thermostats_cache = RedisHandler.get(id)
    return thermostats_cache['household_token'] if thermostats_cache && thermostats_cache['thermostat_id'].to_i == id.to_i && thermostats_cache['household_token'] == request.headers['auth_token']
    raise ExceptionHandler::MissingToken, I18n.t(:token_missing)
  end
end
