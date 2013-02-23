module GitWit::Actions::Dscl
  class Group < Base
    def initialize(base, name, config = {})
      super base, :group, name, config
    end

    protected
    def create
      gid = next_id
      sudo_dscl "create /Groups/#{name}"
      sudo_dscl "create /Groups/#{name} Password '*'"
      sudo_dscl "create /Groups/#{name} PrimaryGroupID #{gid}"
      sudo_dscl "create /Groups/#{name} GroupMembers ''"
    end

    def destroy
      sudo_dscl "delete /Groups/#{name}"
    end
  end
end