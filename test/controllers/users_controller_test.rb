require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user       = users(:michael)
    @other_user = users(:archer)
  end

  def nonadminuser
    {
      user: { 
        password: "password",
        password_confirmation: "password",
        admin: true 
      } 
    }
  end

  test "GET should redirect edit when logged in as wrong user" do
    log_in_as(@other_user)
    get edit_user_path(@user)
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "PATCH should redirect edit when not logged in" do
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should not allow the admin attribute to be edited via the web" do
    log_in_as(@other_user)
    assert_not @other_user.admin?
    patch user_path(@other_user), params: nonadminuser
    assert_not @other_user.admin?                              
  end

  test "PATCH should redirect update when not logged in" do
    patch user_path(@user), params: { 
                                    user: { 
                                      name: @user.name,
                                      email: @user.email 
                                      } 
                                    }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "GET #new should render the new user page " do
    get users_new_url
    assert_response :success
  end
  
  test "should redirect to index when not logged in" do
    get users_path
    assert_redirected_to login_url
  end

end
