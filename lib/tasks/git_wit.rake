namespace "git_wit" do
  namespace "ssh" do
    desc "Debug the SSH configuration"
    task debug: :environment do |t|
      Dir.mktmpdir do |ssh|
        user = "git_wit_shell_test"
        key_file = File.join ssh, "id_rsa"
        pub_key_file = "#{key_file}.pub"

        cmd = %(ssh-keygen -q -t rsa -C "#{user}" -f "#{key_file}" -N "")
        puts "Running #{cmd}"
        `#{cmd}`

        pub_key = File.open(pub_key_file) { |f| f.read }
        debug_key = GitWit::AuthorizedKeys::Key.shell_key_for_username user, pub_key, true
        GitWit.authorized_keys_file.add debug_key
        puts "Added key: #{debug_key}"

        cmd = %(SSH_AUTH_SOCK="" ssh -i "#{key_file}" #{GitWit.ssh_user}@localhost test 123)
        puts "Running #{cmd}"
        out = `#{cmd}`
        puts out
        if $?.success?
          puts "Success"
        else
          puts "ERROR!"
        end
        GitWit.authorized_keys_file.remove debug_key
      end
    end
  end
end