require 'test_helper'
class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  test "GET #home should render the root page, a success response, and a correct title " do
    get root_path
    assert_response :success
    assert_select "title", "Ruby on Rails Tutorial Sample App"
  end
  test "GET #help should render the help page, a success response, and a correct title " do
    get help_path
    assert_response :success
    assert_select "title", "Help | Ruby on Rails Tutorial Sample App"
  end
  test "GET #about should render the about page, a success response, and a correct title " do
    get about_path
    assert_response :success
    assert_select "title", "About | Ruby on Rails Tutorial Sample App"
  end
  test "GET #contact should render the contact page, a success response, and a correct title " do
    get contact_path
    assert_response :success
    assert_select "title", "Contact | Ruby on Rails Tutorial Sample App"
  end end