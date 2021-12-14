class AccountActivationsController < ApplicationController
  def can_authenticate_account?(user)
    (user && !user.activated? && user.authenticated?(:activation, params[:id]))
  end

  def edit
    user = User.find_by(email: params[:email])
    if can_authenticate_account?(user)
      user.activate
      log_in user
      flash[:success] = "Account activated!"
      redirect_to user
    else
      flash[:danger] = "Invalid activation link"
      redirect_to root_url
    end
  end
end