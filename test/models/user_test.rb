require 'test_helper'

class UserTest < ActiveSupport::TestCase
  PASSSWORD_MIN_LENGTH = 6
  NAME_MAX_LENGTH = 51
  EMAIL_MAX_LENGTH = 255
  def setup
    @user = User.new(name: "Example User",
                     email: "user@example.com",
                     password: "foobar",
                     password_confirmation: "foobar")
  end

  test "name should not be too long" do
    @user.name = "a" * NAME_MAX_LENGTH
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.email = "a" * EMAIL_MAX_LENGTH + "@example.com"
    assert_not @user.valid?
  end

  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com
                      USER@foo.COM
                      A_US-ER@foo.bar.org
                      first.last@foo.jp
                      alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "email addresses should be unique" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test "email addresses should be saved as lower-case" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test "password should be present (nonblank)" do
    @user.password = @user.password_confirmation = " " * PASSSWORD_MIN_LENGTH
    assert_not @user.valid?
  end

  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * PASSSWORD_MIN_LENGTH.pred
    assert_not @user.valid?
  end
end