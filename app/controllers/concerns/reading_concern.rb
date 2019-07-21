# frozen_string_literal: true

# Handling thermostat Reading functionlaities
module ReadingConcern
  extend ActiveSupport::Concern
  include ReadingCalc

  def fetch_thermostat(id)
    RedisHandler.get(id)
  end

  def sanitized_params
    update_stats(stats_key)
  end

  def stats_key
    params[:thermostat_id]
  end

  def reading_key
    if params[:tracking_number].nil?
      "reading_#{params[:thermostat_id]}_#{tracking_number}"
    else
      "reading_#{params[:thermostat_id]}_#{params[:tracking_number]}"
    end
  end

  def thermostat_data(id)
    @thermostat_data ||= fetch_thermostat(id)
  end

  def update_stats(id)
    @thermostat_data = thermostat_data(id) && reset_missing_key_if_any?(@thermostat_data)
    @count = tracking_increment
    @thermostat_data = reset_value(@thermostat_data, params, @count)
    @thermostat_data
  end

  def reset_missing_key_if_any?(thermostat_data)
    empty_hash.merge(thermostat_data)
  end

  def reset_value(hash, params_hash, count)
    hash.each do |key, _value|
      if key.include? 'average'
        hash[key] = average(hash[key], params_hash[(key.split('average_')[1]).to_s].to_f, count)
      elsif key.include? 'maximum'
        hash[key] = maximum(hash[key], params_hash[(key.split('maximum_')[1]).to_s].to_f)
      elsif key.include? 'minimum'
        hash[key] = minimum(hash[key], params_hash[(key.split('minimum_')[1]).to_s].to_f)
      elsif key.include? 'tracking_number'
        hash[key] = count
      end
    end
    hash
  end

  def tracking_number
    @thermostat_data['tracking_number'].to_i
  end

  def tracking_increment
    @count = tracking_number
    @count += 1
  end

  def empty_hash
    keys = %w[thermostat_id tracking_number average_temperature average_humidity average_battery_charge maximum_temperature maximum_humidity maximum_battery_charge minimum_temperature minimum_humidity minimum_battery_charge]
    Hash[keys.each_with_object(nil).to_a]
  end

  def valid_params?(params, key = nil)
    if key.nil? && params[:temperature].present? && params[:humidity].present? && params[:battery_charge].present?
      true
    elsif key && params[:thermostat_id].present? && params[:tracking_number].present?
      true
    end
  end
end
