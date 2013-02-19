namespace :git_wit do
  namespace :shell do
    desc "Debug the ssh shell"
    task test: :environment do
      GitWit.run_shell_test(false)
    end
  end
end