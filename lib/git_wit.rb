require "authorized_keys"
require "active_support/configurable"
require "git_wit/engine"
require "git_wit/errors"
require "git_wit/auth"
require "git_wit/shell"
require "git_wit/authorized_keys"
require "git_wit/authorized_keys/key"
require "git_wit/authorized_keys/file"

module GitWit
  include ActiveSupport::Configurable

  config_accessor :repositories_path, :ssh_user, :realm,
    :git_path, :insecure_write, :insecure_auth

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
    end
  end

  class << self
    private :config
  end
end