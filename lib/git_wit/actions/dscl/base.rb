module GitWit::Actions::Dscl
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
      dscl_exists?
    end

    protected
    def id_exists?(check_id)
      dscl_key_exists? "#{type.to_s.first}id", check_id
    end

    def dscl_key_exists?(key, value)
      results = dscl "list /#{type.to_s.capitalize}s #{key}"
      !!(results =~ Regexp.new("#{Regexp.escape(value.to_s)}\n"))
    end

    def dscl_exists?
      results = dscl "list /#{type.to_s.capitalize}s"
      !!(results =~ Regexp.new("#{Regexp.escape(name)}\n"))
    end

    def next_id
      guess = 200
      while id_exists?(guess) && guess < 1000
        guess += 1
      end
      return guess unless id_exists? guess
      raise Thor::Error, "Could not get next #{type.to_s.first}id."
    end

    def dscl(command, config = {})
      command = "dscl . #{command}"
      desc = "#{command} from #{type}"

      if config[:with]
        desc = "#{File.basename(config[:with].to_s)} #{desc}"
        command = "#{config[:with]} #{command}"
      end

      say_status :run, :green, desc if config[:verbose]

      output = `#{command}`
      raise Thor::Error, "dscl command failed: #{desc}" unless $?.success?
      output
    end

    def sudo_dscl(command, config = {})
      dscl command, config.merge(with: "sudo")
    end

    def say_status(status, color, msg = nil)
      msg ||= "#{type} #{name}"
      base.shell.say_status status, msg, color if config[:verbose]
    end
  end
end