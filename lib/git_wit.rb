require "active_support/configurable"
require "git_wit/engine"
require "git_wit/errors"
require "git_wit/auth"
require "git_wit/shell"
require "git_wit/authorized_keys"

module GitWit
  include ActiveSupport::Configurable

  config_accessor :repositories_path, :ssh_user, :realm,
    :git_http_backend_path, :insecure_write, :insecure_auth

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
      config.repositories_path = "/var/git"
      config.ssh_user = "git"
      config.git_http_backend_path = "/usr/libexec/git-core/git-http-backend"
      config.insecure_write = false
      config.insecure_auth = false
    end
  end
end