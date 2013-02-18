require 'test_helper'

class ConfigTest < ActiveSupport::TestCase
  def setup
    GitWit.stash_config
    GitWit.default_config!
  end

  def teardown
    GitWit.restore_config
  end

  test "should expose a configuration interface" do
    assert_kind_of Hash, GitWit.config
    assert !GitWit.config.insecure_write
    GitWit.configure do |config|
      config.insecure_write = true
    end
    assert GitWit.config.insecure_write
  end

  test "should empty the config when reset" do
    GitWit.reset_config!
    assert !GitWit.config.present?
  end

  test "should load reasonable config defaults" do
    assert_kind_of Hash, GitWit.config
    assert GitWit.config.present?
    assert_kind_of String, GitWit.config.realm
    assert_kind_of String, GitWit.config.repositories_path
    assert !GitWit.config.insecure_write
    assert !GitWit.config.insecure_auth
  end

  test "should expose important config parameters directly" do
    %w(repositories_path ssh_user realm git_http_backend_path 
      insecure_write insecure_auth).each do |p|
      assert GitWit.respond_to?(p.to_sym)
    end
  end
end