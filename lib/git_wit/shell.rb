module GitWit
  module Shell
    SHELL_COMMANDS = %w(git-upload-pack git-receive-pack git-upload-archive)

    def self.run
      exec_with_sudo!
      return run_debug if debug?
      boot_app
      command, repository = parse_ssh_original_command
      user = authenticate! ARGV[0]
      authorize! command, user, repository

      repo_path = File.expand_path File.join(GitWit.repositories_path, repository)
      cmd = ["git", "shell", "-c", "#{command} '#{repo_path}'"]
      Rails.logger.info "GitWit SSH command: #{cmd.join " "}"
      exec *cmd
    end

    def self.exec_with_sudo!(user = app_user)
      return if running_as?(user)
      Dir.chdir rails_root
      ENV["TERM"] = "dumb"
      cmd = ["sudo", "-u", "##{app_user}", $PROGRAM_NAME, *ARGV]
      exec *cmd
    end

    def self.debug?
      ARGV.include? "--debug"
    end

    def self.running_as?(user)
      Process.uid == user
    end

    def self.app_user
      File.stat(rails_root).uid
    end

    def self.rails_root
      return File.expand_path(ENV["RAILS_ROOT"]) if ENV["RAILS_ROOT"]
      return File.expand_path("..", ENV["BUNDLE_GEMFILE"]) if ENV["BUNDLE_GEMFILE"]
      Dir.pwd
    end

    def self.boot_app
      require File.expand_path File.join(rails_root, "config/environment")
    end

    def self.parse_ssh_original_command
      /^(?<cmd>git-[^\s]+)\s+'(?<repository>[^']+\.git)'/ =~ ENV["SSH_ORIGINAL_COMMAND"]
      unless SHELL_COMMANDS.include? cmd
        abort "Unknown command: #{ENV["SSH_ORIGINAL_COMMAND"]}" 
      end
      [cmd, repository]
    end

    def self.authenticate(username)
      GitWit.user_for_authentication username
    end

    def self.authenticate!(username)
      user = authenticate username
      abort "Anonymous access denied" if user.nil?
      user
    end

    def self.authorize(command, user, repository)
      op = command == "git-receive-pack" ? :write : :read
      GitWit.authorize op, user, repository
    end

    def self.authorize!(command, user, repository)
      abort "Unauthorized" unless authorize command, user, repository
    end

    def self.run_debug
      require "pp"
      puts "*** GitWit DEBUG ***\n\n"
      puts "ENVIRONMENT:"
      pp ENV
      puts "\n*** GitWit DEBUG ***\n"
    end
  end

  def self.run_shell_test(quiet = true)
    success = false
    Dir.mktmpdir do |ssh|
      user = "git_wit_shell_test"
      key_file = File.join ssh, "id_rsa"
      pub_key_file = "#{key_file}.pub"

      cmd = %(ssh-keygen -q -t rsa -C "#{user}" -f "#{key_file}" -N "")
      puts "Running #{cmd}" unless quiet
      `#{cmd}`

      pub_key = File.open(pub_key_file) { |f| f.read }
      debug_key = AuthorizedKeys::Key.shell_key_for_username user, pub_key, true
      authorized_keys_file.add debug_key
      puts "Added key: #{debug_key}" unless quiet

      cmd = %(SSH_AUTH_SOCK="" ssh -i "#{key_file}" #{GitWit.ssh_user}@localhost test 123)
      puts "Running #{cmd}" unless quiet
      out = `#{cmd}`
      puts out unless quiet
      success = $?.success?
      if success
        puts "Success" unless quiet
      else
        puts "ERROR!" unless quiet
      end
      authorized_keys_file.remove debug_key
    end
    success
  end
end