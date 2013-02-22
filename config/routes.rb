GitWit::Engine.routes.draw do
  get ":repository/*refs", to: "git#service", repository: /[\-\/\w\.]+\.git/
  post ":repository/:service", to: "git#service", repository: /[\-\/\w\.]+\.git/, 
    service: /git-[\w\-]+/
end
