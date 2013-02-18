# Configure GitWit for your application using this initializer.
GitWit.configure do |config|

  # Configure the path to the repositories. This folder should be readable
  # and writable by your application. Use an absolute path for best results.
  # No trailing slash necessary.
  # config.repositories_path = "/var/git"

  # Configure the user for which to manage SSH keys (if enabled.) This user 
  # must be allowed to run gw-ssh (or bundle exec or rvm or whatever) via sudo 
  # as the application user.
  # config.ssh_user = "git"

  # Configure the absolute path to the authorized_keys file for ssh_user. By
  # default, this will be calculated as "~ssh_user/.ssh/authorized_keys". 
  # config.authorized_keys_path = "/var/git/.ssh/authorized_keys"

  # Configure the path to the git-http-backend binary.
  # config.git_http_backend_path = "/usr/libexec/git-core/git-http-backend"

  # Configure the HTTP Basic Auth Realm. Go nuts.
  # config.realm = "GitWit"

  # Allow or disable write operations (push) via non-secure (http) protocols.
  # config.insecure_write = false

  # Allow or disable authentication via non-secure (http) protocols. GitWit uses
  # HTTP Basic authentication, which sends your password in cleartext. This is
  # bad behaviour so the default is to completely disallow authentication
  # without SSL. Note that this will effectively disable insecure write
  # operations as well when set to false, since writes require authentication.
  # config.insecure_auth = false

  # Configure git user attributes. GitWit will "try" these attributes when
  # discerning the user information to pass to git. These may be callables that
  # accept the user model (if authenticated) and should return a string value.
  # If nil (or return nil), reasonable defaults will be used.
  #
  # config.username_attribute = :login          # REMOTE_USER
  # config.committer_email_attribute = :email   # GIT_COMMITTER_NAME
  # config.committer_name_attribute = :name     # GIT_COMMITTER_EMAIL

  # Customize how the user is derived from the username. Below is an example for 
  # devise. Your callable should accept a username return a user model. A string
  # is OK if you don't want to use real models. In fact, the default just 
  # returns the username as the user model. You'll get the user as an argument 
  # to the config.authenticate method later for actual authentication. Returning
  # nil means "authentication failed."
  # 
  # config.user_for_authentication = ->(username) do
  #   user = User.find_for_authentication username: username
  #   user if user.active_for_authentication?
  # end

  # Customize the authentication handler. Below is an example for devise. Your
  # callable should accept a user (from config.user_for_authentication) and 
  # a password. Return a boolean indicating whether the user is autenticated
  # against the given password.
  # 
  # config.authenticate = ->(user, password) do
  #   user.try :valid_password, password
  # end

  # Customize the authorization handlers. There are two - one for read and one
  # for write operations. They will receive the user model (if authenticated)
  # and the repository path as a string (without config.repositories_path 
  # prefixed.) A boolean should be returned. Below are some examples.
  # 
  # config.authorize_read = ->(user, repository) do
  #   repo = Repository.find_by_path repository
  #   repo.public? || repo.user_id = user.id
  # end
  #
  # config.authorize_write = ->(user, repository) do
  #   repo = Repository.find_by_path repository
  #   repo.user_id = user.id || user.admin?
  # end
end