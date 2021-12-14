class SessionsController < ApplicationController
  include SessionsHelper

  def new
  end

  def can_authenticate?(user)
    (user && user.authenticate(params[:session][:password]))
  end

  def create
    @user = User.find_by(email: params.dig(:session, :email)&.downcase)

    if can_authenticate?(@user)
      if @user.activated?
          forwarding_url = session[:forwarding_url]
          reset_session
          log_in @user
          params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
          session[:session_token] = @user.session_token
          redirect_to forwarding_url || @user
        else
          message = "Account not activated. "
          message += "Check your email for the activation link." 
          flash[:warning] = message
          redirect_to root_url
        end
      else
        flash.now[:danger] = 'Invalid email/password combination'
        render 'new'
    end
  end
  # Returns the current logged-in user (if any).
  def current_user
    if (user_id = session[:user_id])
      user ||= User.find_by(id: user_id)
      @current_user ||= user if (user.session_token != session['session_token'])
    elsif (user_id = cookies.encrypted[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(:remember, cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  # Returns true if the given user is the current user.
  def current_user?(user)
    user && user == current_user
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
