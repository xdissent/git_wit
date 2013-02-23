module GitWit::Actions::Ssh
  module Actions
    def ssh_home(user, home, config = {})
      action Home.new(self, user, home, config)
    end

    def ssh_sudoers(user, config = {})
      action Sudoers.new(self, user, config)
    end
  end
end