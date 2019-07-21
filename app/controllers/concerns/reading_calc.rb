# frozen_string_literal: true

# For arithematic manipulations
module ReadingCalc
  extend ActiveSupport::Concern

  def average(old_average, current_value, count)
    if old_average.present?
      ((old_average * (count - 1)) + current_value) / count
    else
      current_value
    end
  end

  def maximum(old_value, new_value)
    if old_value.present?
      old_value >= new_value ? old_value : new_value
    else
      new_value
    end
  end

  def minimum(old_value, new_value)
    if old_value.present?
      old_value >= new_value ? new_value : old_value
    else
      new_value
    end
  end
end
