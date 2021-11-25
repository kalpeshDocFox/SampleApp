require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "GET #new should render the new user page " do
    get users_new_url
    assert_response :success
  end

end
