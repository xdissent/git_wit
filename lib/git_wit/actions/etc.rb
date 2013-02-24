module GitWit::Actions::Etc
  module Actions
    def etc_user(name, home, config = {})
      action User.new(self, name, home, config)
    end
  end
end