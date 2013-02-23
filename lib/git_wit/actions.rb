module GitWit; module Actions; end; end

require "git_wit/actions/ssh"
require "git_wit/actions/ssh/home"
require "git_wit/actions/ssh/sudoers"
require "git_wit/actions/dscl"
require "git_wit/actions/dscl/base"
require "git_wit/actions/dscl/user"
require "git_wit/actions/dscl/group"
require "git_wit/actions/dscl/group_membership"

module GitWit
  module Actions
    include Dscl::Actions
    include Ssh::Actions
  end
end