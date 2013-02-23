module GitWit::Actions::Dscl
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
      @home || "/Users/#{name}"
    end

    def create
      uid = next_id
      sudo_dscl "create /Users/#{name}"
      sudo_dscl "create /Users/#{name} RealName '#{name}'"
      sudo_dscl "create /Users/#{name} UniqueID #{uid}"
      sudo_dscl "create /Users/#{name} NFSHomeDirectory '#{home}'"
      sudo_dscl "create /Users/#{name} UserShell '/bin/bash'"
    end

    def destroy
      sudo_dscl "delete /Users/#{name}"
    end
  end
end