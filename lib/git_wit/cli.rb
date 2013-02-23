require "thor"
require "git_wit/commands/util"
require "git_wit/commands/git_shell"
require "git_wit/commands/debug"

module GitWit
  class Cli < Thor
    include Thor::Actions
    include Commands::Util
    include Commands::GitShell
    include Commands::Debug

    desc "debug", "debug the SSH configuration"
    def debug(*args); super; end

    desc "git-shell USER CMD REPO", "run git-shell CMD as USER in REPO"
    def git_shell(*args); super; end
  end  
end