require "git_wit/actions"

module GitWit
  class SshUserGenerator < Rails::Generators::Base
    include GitWit::Actions

    source_root File.expand_path('../templates', __FILE__)
    
    argument :home, type: :string, required: false

    def check_user
      raise Thor::Error, "GitWit ssh_user is not configured." unless ssh_user.present?
    end

    def create_user
      @home = dscl_user ssh_user, home
    end

    def create_group
      dscl_group ssh_group
    end

    def add_user_to_group
      dscl_group_membership ssh_user, ssh_group
    end

    def build_home
      ssh_home ssh_user, home
    end

    def add_user_to_sudoers
      ssh_sudoers ssh_user
    end

    protected
    def ssh_user
      GitWit.ssh_user
    end
    alias_method :ssh_group, :ssh_user

    def rails_user
      @rails_user ||= `whoami`.strip
    end

    def git_wit_bindir
      bin_path = Rails.root.join("bin", "git_wit")
      return bin_path.dirname.to_s if bin_path.exist?
      bin_path = `which git_wit`.strip
      return File.dirname(bin_path) if bin_path.present?
      raise Thor::Error, "Could not determine path to git_wit executable"
    end
  end
end