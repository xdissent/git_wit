require "tempfile"
require "authorized_keys"

module GitWit
  def self.regenerate_authorized_keys(keymap)
    key_file = authorized_keys_file
    key_file.clear do |file|
      keymap.each do |user, keys|
        keys.each do |key|
          key_file.add AuthorizedKeys::Key.shell_key_for_username(username, key)
        end
      end
    end
  end

  def self.add_authorized_key(username, key)
    authorized_keys_file.add AuthorizedKeys::Key.shell_key_for_username(username, key)
  end

  def self.remove_authorized_key(key)
    authorized_keys_file.remove key
  end

  def self.authorized_keys_file
    AuthorizedKeys::File.new authorized_keys_path
  end

  def self.authorized_keys_path
    File.expand_path("~#{ssh_user}/.ssh/authorized_keys")
  end

  module AuthorizedKeys
    class File < ::AuthorizedKeys::File
      attr_accessor :original_location

      def keys
        list = []
        modify "r" do |file|
          file.each do |line|
            list << Key.new(line.chomp)
          end
        end
        list
      end

      def remove(key)
        key = Key.new(key) if key.is_a?(String)
        cached_keys = keys
        modify 'w' do |file|
          cached_keys.each do |k|
            file.puts k unless key == k
          end
        end
      end

      def owned?
        owner == Process.uid
      end

      def owner(file = nil)
        file ||= location
        ::File.stat(file).uid
      rescue Errno::EACCES
        parent = ::File.dirname file
        owner parent unless file == parent
      end

      def modify(mode, &block)
        return super if owned? || self.original_location
        contents = %x(sudo -u "##{owner}" cat "#{location}") unless mode.include? "w"
        original_owner = owner
        self.original_location = location
        tmp = Tempfile.new "git_wit_authorized_keys"
        self.location = tmp.path
        tmp.write contents unless mode.include? "w"
        tmp.close
        super
        self.location = original_location
        if mode != "r"
          %x(cat "#{tmp.path}" | sudo -u "##{owner}" tee "#{location}" >/dev/null)
        end
        tmp.unlink
        self.original_location = nil
      end

      def clear(&block)
        modify "w", &block
      end
    end

    class Key < ::AuthorizedKeys::Key
      SHELL_OPTIONS = %w(no-port-forwarding no-X11-forwarding 
        no-agent-forwarding no-pty)

      def self.shell_key_for_username(username, key)
        key = self.new key if key.is_a? String
        key.options = [%(command="gw-shell #{username}"), *SHELL_OPTIONS]
        key
      end
    end
  end
end
