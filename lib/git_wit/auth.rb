module GitWit
  def self.user_for_authentication(username)
    if config.user_for_authentication.respond_to?(:call)
      return config.user_for_authentication.call(username)
    end
    username
  end

  def self.authenticate(user, password)
    if config.authenticate.respond_to?(:call)
      return config.authenticate.call(user, password)
    end
    config.authenticate
  end

  def self.authorize_write(user, repository)
    authorize :write, user, repository
  end

  def self.authorize_read(user, repository)
    authorize :read, user, repository
  end

  def self.authorize(operation, user, repository)
    cfg = config.send "authorize_#{operation}".to_sym
    cfg.respond_to?(:call) ? cfg.call(user, repository) : cfg
  end
end