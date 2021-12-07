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

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
