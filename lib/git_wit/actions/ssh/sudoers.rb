module GitWit::Actions::Ssh
  class Sudoers < Thor::Actions::EmptyDirectory

    attr_reader :base, :name

    def initialize(base, name, config = {})
      @base, @name = base, name
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
      `sudo grep '#{sentinel}' /etc/sudoers &>/dev/null`
      $?.success?
    end

    protected
    def sentinel
      "# git_wit sudoers #{name}"
    end

    def real_path
      "/etc/sudoers"
    end

    def lock_path
      "#{real_path}.tmp"
    end

    def append(str)
      `echo '#{str}' | sudo tee -a '#{lock_path}' >/dev/null`
      raise Thor::Error, "Could not append to #{lock_path}" unless $?.success?
    end

    def with_lock(&block)
      `sudo cp -p '#{real_path}' '#{lock_path}'`
      unless $?.success?
        raise Thor::Error, "Could not copy sudoers from #{real_path} to #{lock_path}" 
      end

      old_destination = base.destination_root
      Dir.mktmpdir do |dir|
        base.destination_root = dir
        yield
      end
      base.destination_root = old_destination

      `sudo visudo -cqf '#{lock_path}'`
      unless $?.success?
        raise Thor::Error, "Invalid sudoers lock at #{lock_path}" 
      end

      out = `sudo cat '#{lock_path}'`
      raise Thor::Error, "Refusing to install empty sudoers" unless out.present?

      `sudo mv '#{lock_path}' '#{real_path}'`
      raise Thor::Error, "Could install sudoers from #{lock_path} to #{real_path}" unless $?.success?
    ensure
      `sudo rm -rf '#{lock_path}'`
    end

    def create
      with_lock do
        base.template "sudoers.tt"
        append sentinel
        `cat '#{base.destination_root}/sudoers' | sudo tee -a '#{lock_path}' >/dev/null`
        raise Thor::Error, "Could not modify #{lock_path}" unless $?.success?
        append sentinel
      end
    end

    def destroy
      with_lock do
        `sudo cat '#{lock_path}' | sed -e '/^#{sentinel}/,/^#{sentinel}/d' > '#{base.destination_root}/sudoers'`
        `cat '#{base.destination_root}/sudoers' | sudo tee '#{lock_path}' >/dev/null`
        raise Thor::Error, "Could not modify #{lock_path}" unless $?.success?
      end
    end

    def relative_destination
      "sudoers #{name}"
    end
  end
end