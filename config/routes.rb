# frozen_string_literal: true

require 'api_constraints'
Rails.application.routes.draw do
  # Api definition
  namespace :api do
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: true) do
      resources :thermostats, only: [:show] do
        resources :readings, only: %i[show create], param: :tracking_number
      end
    end
  end
end
