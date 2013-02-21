module GitWit
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
      rescue Errno::EACCES, Errno::ENOENT
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
  end
end