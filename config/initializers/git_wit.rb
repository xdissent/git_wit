# Configures GitWit defaults (before app initializer)
GitWit.configure do |config|
  config.realm = "GitWit"
  config.repositories_path = "/var/git"
  config.manage_ssh = false
  config.ssh_user = "git"
  config.git_http_backend_path = "/usr/libexec/git-core/git-http-backend"
  config.insecure_write = false
  config.insecure_auth = false
end