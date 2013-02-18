class Repository < ActiveRecord::Base
  belongs_to :user
  attr_accessible :name, :path, :public

  validates :path, presence: true, 
    uniqueness: { case_sensitive: false },
    format: { with: /\A[\-\/\w\.]+\.git\z/, message: "Invalid characters in path" }
  validate :check_path_not_exists, on: :create
  
  def create_git_repository
    Grit::Repo.init_bare git_repository_path
  end

  def destroy_git_repository
    FileUtils.rm_rf git_repository_path
  end

  def git_repository_path
    File.join(GitWit.repositories_path, path)
  end

  def check_path_not_exists
    if File.exists? git_repository_path
      errors.add :path, :taken unless errors.keys.include? :path
    end
  end
end
