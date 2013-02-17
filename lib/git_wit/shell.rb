module GitWit
  module Shell
    SHELL_COMMANDS = %w(git-upload-pack git-receive-pack git-upload-archive)
    SUDO_ENV_KEYS = %w(SSH_ORIGINAL_COMMAND GEM_HOME GEM_PATH PATH 
      BUNDLE_GEMFILE RAILS_ENV)

    def self.exec_with_sudo!(user = app_user)
      return if running_as?(user)
      Dir.chdir rails_root
      env = SUDO_ENV_KEYS.map { |k| "#{k}=#{ENV[k]}" if ENV[k] }.compact
      env << "RAILS_ROOT=#{rails_root}" << "TERM=dumb"
      cmd = ["sudo", "-u", "##{app_user}", *env, "-s", $PROGRAM_NAME, *ARGV]
      exec *cmd
    end

    def self.running_as?(user)
      Process.uid == user
    end

    def self.app_user
      File.stat(rails_root).uid
    end

    def self.rails_root
      (File.expand_path(ENV["RAILS_ROOT"]) || 
        File.expand_path("..", ENV["BUNDLE_GEMFILE"]) || Dir.pwd)
    end

    def self.boot_app
      require File.expand_path File.join(rails_root, "config/environment")
    end

    def self.parse_ssh_original_command
      /^(?<cmd>git-[^\s]+)\s+'(?<repository>[^']+\.git)'/ =~ ENV["SSH_ORIGINAL_COMMAND"]
      abort "Uknown command #{cmd}" unless SHELL_COMMANDS.include? cmd
      [cmd, repository]
    end

    def self.authenticate
      user = GitWit.user_for_authentication ARGV[0]
      abort "Anonymous access denied" unless user.present?
      user
    end

    def self.authorize(command, user, repository)
      op = command == "git-receive-pack" ? :write : :read
      abort "Unauthorized" unless GitWit.authorize op, user, repository
    end

    def self.run
      exec_with_sudo!
      boot_app
      command, repository = parse_ssh_original_command
      user = authenticate
      authorize command, user, repository

      repo_path = File.expand_path File.join(GitWit.repositories_path, repository)
      cmd = ["git", "shell", "-c", "#{command} '#{repo_path}'"]
      Rails.logger.info "GitWit SSH command: #{cmd.join " "}"
      exec *cmd
    end
  end
end