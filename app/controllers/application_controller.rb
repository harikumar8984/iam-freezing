# frozen_string_literal: true

# ApplicationController
class ApplicationController < ActionController::API
  include AuthenticationConcern
  include ExceptionHandler
  before_action :set_locale
  before_action :authenticate

  def authenticate
    return true if token?(params)

    raise ExceptionHandler::AuthenticationError, I18n.t(:not_athenticated)
  end

  private
  
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options
    { locale: I18n.locale }
  end
end
