class GitWit::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path('../../templates', __FILE__)

  def copy_initializer
    template "git_wit.rb", "config/initializers/git_wit.rb"
  end

  def show_readme
    readme "README" if behavior == :invoke
  end
end
