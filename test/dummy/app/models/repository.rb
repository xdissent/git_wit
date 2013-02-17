class Repository < ActiveRecord::Base
  belongs_to :user
  attr_accessible :name, :path, :public

  def create_git_repository
    Grit::Repo.init_bare git_repository_path
  end

  def destroy_git_repository
    FileUtils.rm_rf git_repository_path
  end

  def git_repository_path
    File.join(GitWit.repositories_path, path)
  end
end
