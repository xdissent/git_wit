module GitWit::Actions::Etc
  class Base < Thor::Actions::EmptyDirectory

    attr_reader :base, :type, :name

    def initialize(base, type, name, config = {})
      @base, @type, @name = base, type, name
      @config = {verbose: true}.merge config
    end

    def invoke!
      invoke_with_conflict_check do
        create
      end
    end

    def revoke!
      say_status :remove, :red
      destroy if !pretend? && exists?
    end

    def exists?
      etc_exists?
    end

    protected
    def etc_exists?
      file = type == :user ? "passwd" : "group"
      `grep '#{name}:x:' /etc/#{file}`
      $?.success?
    end

    def say_status(status, color, msg = nil)
      msg ||= "#{type} #{name}"
      base.shell.say_status status, msg, color if config[:verbose]
    end
  end
end