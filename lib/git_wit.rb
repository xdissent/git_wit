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
end