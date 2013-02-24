require 'test_helper'

class CliTest < ActiveSupport::TestCase
  # def setup
  #   GitWit.stash_config
  #   GitWit.default_config!
  # end

  # def teardown
  #   GitWit.restore_config
  # end

  # test "should use RAILS_ROOT env variable if given" do
  #   old_root = ENV.delete "RAILS_ROOT"

  #   ENV["RAILS_ROOT"] = "/example/rails/app"
  #   assert_equal ENV["RAILS_ROOT"], GitWit::Shell.rails_root

  #   ENV["RAILS_ROOT"] = old_root
  # end

  # test "should use BUNDLE_GEMFILE env variable if no rails root" do
  #   old_root = ENV.delete "RAILS_ROOT"
  #   old_bundle = ENV.delete "BUNDLE_GEMFILE"

  #   ENV["BUNDLE_GEMFILE"] = "/another/rails/app/Gemfile"
  #   assert_equal "/another/rails/app", GitWit::Shell.rails_root

  #   ENV["RAILS_ROOT"] = old_root
  #   ENV["BUNDLE_GEMFILE"] = old_bundle
  # end

  # test "should use current directory if no RAILS_ROOT or BUNDLE_GEMFILE given" do
  #   old_root = ENV.delete "RAILS_ROOT"
  #   old_bundle = ENV.delete "BUNDLE_GEMFILE"

  #   tmp_dir = Rails.root.join("tmp").to_s
  #   assert Dir.exist?(tmp_dir)
  #   Dir.chdir(tmp_dir) do
  #     assert_equal tmp_dir, GitWit::Shell.rails_root
  #   end

  #   ENV["RAILS_ROOT"] = old_root
  #   ENV["BUNDLE_GEMFILE"] = old_bundle
  # end

  # test "should deduce the app user from file ownership of rails root" do
  #   old_root = ENV.delete "RAILS_ROOT"

  #   ENV["RAILS_ROOT"] = Rails.root.to_s
  #   assert_equal Process.uid, GitWit::Shell.app_user

  #   ENV["RAILS_ROOT"] = old_root
  # end

  # test "should know if it's running as a given user" do
  #   assert GitWit::Shell.running_as?(Process.uid)
  # end

  # test "should parse git commands into command and repository path" do
  #   ENV["SSH_ORIGINAL_COMMAND"] = "#{GitWit::Shell::SHELL_COMMANDS.first} 'example.git'"
  #   cmd_repo = GitWit::Shell.parse_ssh_original_command
  #   assert_equal 2, cmd_repo.length
  #   assert_equal GitWit::Shell::SHELL_COMMANDS.first, cmd_repo.first
  #   assert_equal "example.git", cmd_repo.last
  #   ENV.delete "SSH_ORIGINAL_COMMAND"
  # end

  # test "should authenticate by only confirming that a user exists" do
  #   GitWit.configure { |c| c.user_for_authentication = ->(username) { "xxxx" } }
  #   GitWit.configure { |c| c.authenticate = ->(user, password) { raise "tried auth" } }
  #   assert_nothing_raised do
  #     assert_equal "xxxx", GitWit::Shell.authenticate("example")
  #   end
  #   GitWit.configure { |c| c.user_for_authentication = ->(username) { nil } }
  #   assert_nothing_raised do
  #     assert_nil GitWit::Shell.authenticate("example")
  #   end
  # end

  # test "should authorize read/write based on git command given" do
  #   GitWit.configure { |c| c.authorize_write = ->(user, repository) { user == "w" } }
  #   GitWit.configure { |c| c.authorize_read = ->(user, repository) { user == "r" } }
  #   assert GitWit::Shell.authorize("git-receive-pack", "w", "example.git")
  #   assert !GitWit::Shell.authorize("git-receive-pack", "r", "example.git")
  #   assert !GitWit::Shell.authorize("git-upload-pack", "w", "example.git")
  #   assert GitWit::Shell.authorize("git-upload-pack", "r", "example.git")
  # end
end