module GitWit::Actions::Ssh
  class Home < Thor::Actions::EmptyDirectory
    attr_reader :base, :user, :home

    def initialize(base, user, home, config = {})
      @base, @user, @home = base, user, File.expand_path(home)
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
      home
    end

    def exists?
      Dir.exists? home
    end

    protected
    def create
      old_destination = base.destination_root
      Dir.mktmpdir do |dir|
        base.destination_root = dir
        base.inside "." do
          base.empty_directory ".ssh"
          base.chmod ".ssh", 0700
          base.inside ".ssh" do
            base.create_file "authorized_keys", ""
            base.chmod "authorized_keys", 0600
          end
          base.template "bashrc.tt", ".bashrc"
        end
        base.chmod ".", 0755
        `sudo cp -R '#{dir}' '#{home}'`
        `sudo chown -R #{user}:#{user} '#{home}'`
      end
      base.destination_root = old_destination
    end

    def destroy
      `sudo rm -rf '#{home}'`
    end

    def relative_destination
      home
    end
  end
end