require 'test_helper'
class PasswordResetsTest < ActionDispatch::IntegrationTest
  def setup 
    ActionMailer::Base.deliveries.clear 
    @user = users(:michael)
  end

  test "password resets check for empty email input validate reload and check for flash message" do
    get new_password_reset_path
    assert_template 'password_resets/new'
    assert_select 'input[name=?]', 'password_reset[email]'
    # Invalid email
    post password_resets_path, params: { password_reset: { email: "" } } 
    assert_not flash.empty?
    assert_template 'password_resets/new'
  end

  test "password resets valid email confirm email and redirect to root" do
    get new_password_reset_path
    assert_template 'password_resets/new'
    assert_select 'input[name=?]', 'password_reset[email]'
    # Valid email
    post password_resets_path,params: { password_reset: { email: @user.email } } 
    assert_not_equal @user.reset_digest, @user.reload.reset_digest 
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url
  end
  

  test "password resets fill in wrong email address after mail" do
    get new_password_reset_path
    assert_template 'password_resets/new'
    assert_select 'input[name=?]', 'password_reset[email]'
    # Valid email
    post password_resets_path,params: { password_reset: { email: @user.email } } 
    assert_not_equal @user.reset_digest, @user.reload.reset_digest 
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url
    # Password reset form
    user = assigns(:user)
    # Wrong email
    get edit_password_reset_path(user.reset_token, email: "") 
    assert_redirected_to root_url
  end

  test "password reset with inactive user" do
    get new_password_reset_path
    assert_template 'password_resets/new'
    assert_select 'input[name=?]', 'password_reset[email]'
    # Valid email
    post password_resets_path,params: { password_reset: { email: @user.email } } 
    assert_not_equal @user.reset_digest, @user.reload.reset_digest 
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url
    # Password reset form
    user = assigns(:user)
    # Inactive user
    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token, email: user.email) 
    assert_redirected_to root_url
    user.toggle!(:activated)
  end

  test "password reset with wrong token" do
    get new_password_reset_path
    assert_template 'password_resets/new'
    assert_select 'input[name=?]', 'password_reset[email]'
    # Valid email
    post password_resets_path,params: { password_reset: { email: @user.email } } 
    assert_not_equal @user.reset_digest, @user.reload.reset_digest 
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url
    # Password reset form
    user = assigns(:user)
    # Right email, wrong token
    get edit_password_reset_path('wrong token', email: user.email) 
    assert_redirected_to root_url
  end

  test "password reset with valid email and token" do
    get new_password_reset_path
    assert_template 'password_resets/new'
    assert_select 'input[name=?]', 'password_reset[email]'
    # Valid email
    post password_resets_path,params: { password_reset: { email: @user.email } } 
    assert_not_equal @user.reset_digest, @user.reload.reset_digest 
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url
    # Password reset form
    user = assigns(:user)
    # Right email, right token
    get edit_password_reset_path(user.reset_token, email: user.email) 
    assert_template 'password_resets/edit'
    assert_select "input[name=email][type=hidden][value=?]", user.email 
  end

  test "password reset missmatch password and confirm password" do
    get new_password_reset_path
    assert_template 'password_resets/new'
    assert_select 'input[name=?]', 'password_reset[email]'
    # Valid email
    post password_resets_path,params: { password_reset: { email: @user.email } } 
    assert_not_equal @user.reset_digest, @user.reload.reset_digest 
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url
    # Password reset form
    user = assigns(:user)
    # Invalid password & confirmation
    patch password_reset_path(user.reset_token),
              params: { email: user.email,
                        user: { 
                          password:"foobaz",
                          password_confirmation: "barquux" 
                        } 
                      } 
    assert_select 'div#error_explanation'
  end 

  test "password reset empty password" do
    get new_password_reset_path
    assert_template 'password_resets/new'
    assert_select 'input[name=?]', 'password_reset[email]'
    # Valid email
    post password_resets_path,params: { password_reset: { email: @user.email } } 
    assert_not_equal @user.reset_digest, @user.reload.reset_digest 
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url
    # Password reset form
    user = assigns(:user)
    # Empty password
    patch password_reset_path(user.reset_token), 
                params: { email: user.email,
                        user: { 
                          password:"",
                          password_confirmation: "" 
                          } 
                        }
    assert_select 'div#error_explanation'
  end
  
  test "password reset valid password and confirm password" do
    get new_password_reset_path
    assert_template 'password_resets/new'
    assert_select 'input[name=?]', 'password_reset[email]'
    # Valid email
    post password_resets_path,params: { password_reset: { email: @user.email } } 
    assert_not_equal @user.reset_digest, @user.reload.reset_digest 
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url
    # Password reset form
    user = assigns(:user)
    # Valid password & confirmation
    patch password_reset_path(user.reset_token),
              params: { email: user.email,
                        user: { 
                          password:"foobaz",
                          password_confirmation: "foobaz" 
                        } 
                      }
    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to user
  end
end