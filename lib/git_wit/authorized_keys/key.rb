module GitWit
  module AuthorizedKeys
    class Key < ::AuthorizedKeys::Key
      SHELL_OPTIONS = %w(no-port-forwarding no-X11-forwarding 
        no-agent-forwarding no-pty)

      def self.shell_key_for_username(username, key, debug = false)
        key = self.new key if key.is_a? String
        cmd = debug ? "debug" : "git-shell #{username}"
        key.options = [%(command="git_wit #{cmd}"), *SHELL_OPTIONS]
        key
      end
    end
  end
end