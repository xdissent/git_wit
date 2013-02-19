$:.push File.expand_path("../lib", __FILE__)

require "git_wit/version"

Gem::Specification.new do |s|
  s.name        = "git_wit"
  s.version     = GitWit::VERSION
  s.authors     = ["Greg Thornton"]
  s.email       = ["xdissent@me.com"]
  s.homepage    = "http://xdissent.github.com/git_wit/"
  s.description = s.summary = "Dead simple Git hosting for Rails apps."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]
  s.executables << "gw-shell"

  s.add_dependency "rails", "~> 3.2.12"
  s.add_dependency "authorized_keys", "~> 1.1.1"
end
