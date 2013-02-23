module GitWit::Actions::Dscl
  module Actions
    def dscl_user(name, home, config = {})
      action User.new(self, name, home, config)
    end

    def dscl_group(name, config = {})
      action Group.new(self, name, config)
    end

    def dscl_group_membership(user, group, config = {})
      action GroupMembership.new(self, user, group, config)
    end
  end
end