module GitWit
  module Commands
    module GitShell
      GIT_SHELL_COMMAND_RE = /^(git-[^\s]+)\s+'([^']+\.git)'/
      GIT_SHELL_COMMANDS = %w(git-upload-pack git-receive-pack git-upload-archive)

      def git_shell(user, cmd = nil, repo = nil)
        @command, @repository, @user = cmd, repo, nil
        exec_with_sudo!
        boot_app
        parse_ssh_original_command if ENV["SSH_ORIGINAL_COMMAND"].present?
        validate_git_shell_command
        authenticate user
        authorize
        run_git_shell
      end

      protected
      def parse_ssh_original_command
        @command, @repository = GIT_SHELL_COMMAND_RE.match(ENV["SSH_ORIGINAL_COMMAND"])
      end

      def validate_git_shell_command
        unless GIT_SHELL_COMMANDS.include? @command
          abort "Unknown git shell command: #{@command}" 
        end
      end

      def authenticate(user)
        @user = GitWit.user_for_authentication user
        authenticate(user)
        abort "Anonymous access denied via SSH" unless @user.present?
      end

      def authorize
        op = @command == "git-receive-pack" ? :write : :read
        GitWit.authorize op, @user, @repository
        abort "Unauthorized" unless authorize
      end

      def run_git_shell
        repo_path = File.expand_path File.join(GitWit.repositories_path, @repository)
        cmd = [GitWit.git_path, "shell", "-c", "#{@command} '#{repo_path}'"]
        Rails.logger.info "GitWit SSH cmd: #{cmd.join " "}"
        exec *cmd
      end
    end
  end
end