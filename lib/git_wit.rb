require "active_support/configurable"
require "git_wit/engine"
require "git_wit/errors"
require "git_wit/auth"

module GitWit
  include ActiveSupport::Configurable

  config_accessor :repositories_path, :manage_ssh, :ssh_user, :realm,
    :git_http_backend_path, :insecure_write, :insecure_auth
end