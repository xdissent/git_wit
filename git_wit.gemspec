$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "git_wit/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "git_wit"
  s.version     = GitWit::VERSION
  s.authors     = ["Greg Thornton"]
  s.email       = ["xdissent@me.com"]
  s.homepage    = "http://xdissent.com"
  s.summary     = "A simple Git server for Rails."
  s.description = "TODO: Description of GitWit."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]
  s.executables << "gw-shell"

  s.add_dependency "rails", "~> 3.2.12"
end
