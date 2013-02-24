module GitWit::Actions::Etc
  class User < Base
    def initialize(base, name, home, config = {})
      super base, :user, name, config
      @home = home
    end

    def invoke!
      invoke_with_conflict_check do
        create
      end
      home
    end

    def revoke!
      say_status :remove, :red
      destroy if !pretend? && exists?
      home
    end

    protected
    def home
      @home || "/home/#{name}"
    end

    def create
      `sudo useradd -M -U -r -s '/bin/bash' -d '#{home}' '#{name}'`
      raise Thor::Error, "Could not create user #{name}" unless $?.success?
    end

    def destroy
      `sudo userdel -r '#{name}'`
      raise Thor::Error, "Could not destroy user #{name}" unless $?.success?
    end
  end
end