require 'api_constraints'
Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
# Api definition
	namespace :api do
	  scope module: :v1, constraints: ApiConstraints.new(version: 1, default: true) do
	    resources :thermostats, only:[:show]  do
				resources :readings, only: [:show, :create], param: :tracking_number
			end
	  end
	end
end
