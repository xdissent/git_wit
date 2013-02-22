require 'test_helper'

module GitWit
  def self._config; @_config; end
end

class ConfigTest < ActiveSupport::TestCase
  def setup
    GitWit.stash_config
    GitWit.default_config!
  end

  def teardown
    GitWit.restore_config
  end

  test "should expose a configuration interface" do
    assert_kind_of Hash, GitWit._config
    assert !GitWit._config.insecure_write
    GitWit.configure do |config|
      config.insecure_write = true
    end
    assert GitWit._config.insecure_write
  end

  test "should empty the config when reset" do
    GitWit.reset_config!
    assert !GitWit._config.present?
  end

  test "should load reasonable config defaults" do
    assert_kind_of Hash, GitWit._config
    assert GitWit._config.present?
    assert_kind_of String, GitWit._config.realm
    assert_kind_of String, GitWit._config.repositories_path
    assert !GitWit._config.insecure_write
    assert !GitWit._config.insecure_auth
  end

  test "should expose important config parameters directly" do
    %w(repositories_path ssh_user realm git_path 
      insecure_write insecure_auth).each do |p|
      assert GitWit.respond_to?(p.to_sym)
    end
  end
end