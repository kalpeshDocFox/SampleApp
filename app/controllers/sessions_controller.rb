class SessionsController < ApplicationController
  include SessionsHelper

  def new
  end

  def create
    @user = User.find_by(email: params[:session][:email].downcase)
    if can_authenticate?(@user)
      reset_session
      log_in @user
      params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
      session[:session_token] = @user.session_token
      redirect_to @user
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def current_user
    if session[:user_id]
      User.find_by(id: session[:user_id])
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
