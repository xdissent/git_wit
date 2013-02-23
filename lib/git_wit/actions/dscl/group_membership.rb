module GitWit::Actions::Dscl
  class GroupMembership < Base
    attr_reader :user, :group

    def initialize(base, user, group, config = {})
      super base, :group_membership, "#{user} #{group}", config
      @user, @group = user, group
    end

    def exists?
      check = `dsmemberutil checkmembership -U '#{user}' -G '#{group}' 2>/dev/null`
      $?.success? && !!(check =~ /is a member/)
    end

    protected
    def create
      sudo_dscl "create /Users/#{user} PrimaryGroupID #{gid}"
      sudo_dscl "append /Groups/#{group} GroupMembership #{user}"
    end
    
    def destroy
    end

    def gid
      gid = dscl "read /Groups/#{group} gid".split("gid: ", 2).last
      raise Thor::Error, "Could not find gid for group #{group}" unless gid.present?
      gid.to_i
    end
  end
end