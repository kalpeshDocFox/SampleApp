require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  test "can successfully sign up a user with valid params" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, params: { user: {
                                  name: "",
                                  email: "user@invalid",
                                  password: "foo",
                                  password_confirmation: "bar" } }
    end
    assert_template 'users/new'
  end

  test "test to confirm with valid signup information" do
    get signup_path
    assert_difference 'User.count', 1 do
<<<<<<< HEAD
      post users_path, params: { user: {
                                name: "Example User",
                                email: "user@example.com",
                                password: "password",
                                confirm_password: "password" } }
=======
      post users_path, params: params
>>>>>>> 9794bf7 (Update test/integration/users_signup_test.rb)
    end
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
  end
end