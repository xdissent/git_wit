require 'test_helper'

class AuthorizedKeysTest < ActiveSupport::TestCase
  def setup
    GitWit.stash_config
    GitWit.default_config!
    GitWit.config.ssh_user = `whoami`.chomp
    @tmp_keys_path = Rails.root.join("tmp", "authorized_keys").to_s
  end

  def teardown
    GitWit.restore_config
    File.unlink @tmp_keys_path if File.exist? @tmp_keys_path
  end

  test "should calculate appropriate authorized_keys path for ssh_user" do
    app_user_keys_path = File.expand_path("~/.ssh/authorized_keys")
    assert_equal app_user_keys_path, GitWit.authorized_keys_path
  end

  test "should accept an absolute path for authorized_keys_path in config" do
    GitWit.config.authorized_keys_path = @tmp_keys_path
    assert_equal @tmp_keys_path, GitWit.authorized_keys_path
  end

  test "should generate authorized_keys from key map" do
    GitWit.config.authorized_keys_path = @tmp_keys_path
    GitWit.regenerate_authorized_keys(
      "one" => ["ssh-rsa fakekey1 one@fake1", "ssh-rsa fakekey2 one@fake2"], 
      "two" => ["ssh-rsa fakekey3 two@fake"])
    key_file = GitWit.authorized_keys_file
    assert_equal 3, key_file.keys.length
    assert_equal 2, key_file.keys.map(&:options).map(&:to_s).uniq.length
  end

  test "should be able to add keys one at a time" do
    GitWit.config.authorized_keys_path = @tmp_keys_path
    key_file = GitWit.authorized_keys_file
    GitWit.add_authorized_key "one", "ssh-rsa fakekey1 one@fake1"
    assert_equal 1, key_file.keys.length
    GitWit.add_authorized_key "one", "ssh-rsa fakekey2 one@fake2"
    assert_equal 2, key_file.keys.length
  end

  test "should be able to remove keys one at a time" do
    GitWit.config.authorized_keys_path = @tmp_keys_path
    GitWit.regenerate_authorized_keys(
      "one" => ["ssh-rsa fakekey1 one@fake1", "ssh-rsa fakekey2 one@fake2"], 
      "two" => ["ssh-rsa fakekey3 two@fake"])
    key_file = GitWit.authorized_keys_file
    assert_equal 3, key_file.keys.length
    GitWit.remove_authorized_key "ssh-rsa fakekey1 one@fake1"
    assert_equal 2, key_file.keys.length
    GitWit.remove_authorized_key "ssh-rsa fakekey2 one@fake2"
    assert_equal 1, key_file.keys.length
  end
end