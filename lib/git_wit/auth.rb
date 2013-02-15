module GitWit
  def self.authenticate(username, password)
    if config.authenticate.respond_to?(:call)
      config.authenticate.call(username, password)
    end
  end

  def self.authorize_write(user, repository)
    authorize :write, user, repository
  end

  def self.authorize_read(user, repository)
    authorize :read, user, repository
  end

  def self.authorize(operation, user, repository)
    cfg = config.send "authorize_#{operation}".to_sym
    cfg.respond_to?(:call) ? cfg.call(user, repository) : false
  end
end