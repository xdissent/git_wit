require "authorized_keys"
require "active_support/configurable"
require "git_wit/engine"
require "git_wit/errors"
require "git_wit/auth"
require "git_wit/authorized_keys"
require "git_wit/authorized_keys/key"
require "git_wit/authorized_keys/file"
require "git_wit/cli"

module GitWit
  include ActiveSupport::Configurable

  config_accessor :repositories_path, :ssh_user, :realm,
    :git_path, :insecure_write, :insecure_auth, :username_attribute,
    :email_attribute, :name_attribute

  def self.reset_config!
    @_config = nil
  end

  def self.stash_config
    @_stashed = @_config.dup
  end

  def self.restore_config
    @_config = @_stashed
    @_stashed = nil
  end

  def self.default_config!
    reset_config!
    configure do |config|
      config.realm = "GitWit"
      config.repositories_path = Rails.root.join("repositories").to_s
      config.ssh_user = nil
      config.git_path = "git"
      config.insecure_write = false
      config.insecure_auth = false
      config.authenticate = false
      config.authorize_read = false
      config.authorize_write = false
      config.username_attribute = :login
      config.email_attribute = :email
      config.name_attribute = :name
    end
  end

  class << self
    private :config
  end
end