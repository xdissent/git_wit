GitWit::Engine.routes.draw do
  get ":repository/*refs" => "git#service", repository: /[-\/\w\.]+\.git/
  post ":repository/:service" => "git#service", repository: /[-\/\w\.]+\.git/, 
    service: /git-[\w\-]+/
end
