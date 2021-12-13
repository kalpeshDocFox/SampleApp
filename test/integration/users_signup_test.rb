require 'test_helper'
class UsersSignupTest < ActionDispatch::IntegrationTest

  def setup 
    ActionMailer::Base.deliveries.clear
  end
  
  def params_valid_user
    { user: {
      name: "Example User",
      email: "user@example.com",
      password: "password",
      confirm_password: "password" 
      } 
    }
  end

  def params_signup_valid
    { user: {
        name: "",
        email: "user@invalid",
        password: "foo",
        password_confirmation: "bar" 
        } 
      }
  end

  test "can successfully sign up a user with valid params" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, params: params_signup_valid
    end
    assert_template 'users/new'
  end

  test "test to confirm with valid signup information" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params: params_valid_user
    end
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
  end

  test "valid signup information with account activation" do get signup_path
    assert_difference 'User.count', 1 do
    post users_path, params: params_valid_user
    end
    assert_equal 1, ActionMailer::Base.deliveries.size 
    user = assigns(:user)
    assert_not user.activated?
    # Try to log in before activation.
    log_in_as(user)
    assert_not is_logged_in?
    get edit_account_activation_path("invalid token", email: user.email) 
    assert_not is_logged_in?
    # Valid token, wrong email
    get edit_account_activation_path(user.activation_token, email: 'wrong') 
    assert_not is_logged_in?
    # Valid activation token
    get edit_account_activation_path(user.activation_token, email: user.email) 
    assert user.reload.activated?
    follow_redirect!
    assert is_logged_in?
    end 
  
  end