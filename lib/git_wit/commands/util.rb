module GitWit
  module Commands
    module Util
      def exec_with_sudo!(user = app_user)
        return if running_as?(user)
        Dir.chdir rails_root
        ENV["TERM"] = "dumb"
        cmd = ["sudo", "-u", "##{user}", $PROGRAM_NAME, *ARGV]
        exec *cmd
      end

      def running_as?(user)
        Process.uid == user
      end

      def app_user
        File.stat(rails_root).uid
      end

      def rails_root
        return File.expand_path(ENV["RAILS_ROOT"]) if ENV["RAILS_ROOT"]
        return Dir.pwd if File.exist? File.join(Dir.pwd, "config/environment.rb")
        return File.expand_path("..", ENV["BUNDLE_GEMFILE"]) if ENV["BUNDLE_GEMFILE"]
        Dir.pwd
      end

      def boot_app
        require File.expand_path File.join(rails_root, "config/environment") unless booted?
        require "git_wit"
      end

      def booted?
        defined?(Rails)
      end
    end  
  end
end