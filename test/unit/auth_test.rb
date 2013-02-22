require 'test_helper'

class AuthTest < ActiveSupport::TestCase
  def setup
    GitWit.stash_config
    GitWit.default_config!
  end

  def teardown
    GitWit.restore_config
  end

  test "should use username as user model for authentication by default" do
    assert_equal "example", GitWit.user_for_authentication("example")
  end

  test "should allow custom user lookups for authentication" do
    GitWit.configure { |c| c.user_for_authentication = ->(username) { "xxxx" } }
    assert_equal "xxxx", GitWit.user_for_authentication("example")
  end

  test "should always fail authentication by default" do
    assert !GitWit.authenticate("example", "password")
  end

  test "should allow custom user authentication" do
    GitWit.configure { |c| c.authenticate = ->(user, password) { user == password } }
    assert !GitWit.authenticate("example", "password")
    assert GitWit.authenticate("example", "example")
    assert GitWit.authenticate("password", "password")
  end

  test "should not authorize read by default" do
    assert !GitWit.authorize_read("example", "test.git")
  end

  test "should allow custom read authorization" do
    GitWit.configure do |c|
      c.authorize_read = ->(user, repository) do
        repository == "#{user}.git"
      end
    end
    assert !GitWit.authorize_read("example", "test.git")
    assert GitWit.authorize_read("example", "example.git")
  end

  test "should not authorize write by default" do
    assert !GitWit.authorize_write("example", "test.git")
  end

  test "should allow custom write authorization" do
    GitWit.configure do |c|
      c.authorize_write = ->(user, repository) do
        repository == "#{user}.git"
      end
    end
    assert !GitWit.authorize_write("example", "test.git")
    assert GitWit.authorize_write("example", "example.git")
  end
end