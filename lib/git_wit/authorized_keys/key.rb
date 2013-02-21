module GitWit
  module AuthorizedKeys
    class Key < ::AuthorizedKeys::Key
      SHELL_OPTIONS = %w(no-port-forwarding no-X11-forwarding 
        no-agent-forwarding no-pty)

      def self.shell_key_for_username(username, key, debug = false)
        key = self.new key if key.is_a? String
        debug = debug ? "--debug " : ""
        key.options = [%(command="gw-shell #{debug}#{username}"), *SHELL_OPTIONS]
        key
      end
    end
  end
end