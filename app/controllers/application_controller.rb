class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :load_settings
  helper_method :current_user, :user_signed_in?

  def current_user_is_admin!
    current_user && current_user.email.in?(ENV.fetch("ADMIN_EMAIL").split(','))
  end

  def current_user
    return false unless session[:userinfo].present?
    @current_user ||= User.where(email: Hash(session[:userinfo]).dig("info", "email")).first_or_create!
  end

  def user_signed_in?
    session[:userinfo].present?
  end


  private

  def load_settings
    @settings ||= SiteSetting.new
  end

  def require_user_signed_in
    unless user_signed_in?

      # If the user came from a page, we can send them back.  Otherwise, send
      # them to the root path.
      if request.env['HTTP_REFERER']
        fallback_redirect = :back
      elsif defined?(root_path)
        fallback_redirect = root_path
      else
        fallback_redirect = "/"
      end

      redirect_to fallback_redirect, flash: {error: "You must be signed in to view this page."}
    end
  end


  # If your model is called User
  def after_sign_in_path_for(resource)
    session["user_return_to"] || new_post_path
  end


end
