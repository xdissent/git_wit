GitWit::Engine.routes.draw do
  match ":repository/*refs" => "git#service", 
    repository: /[-\/\w\.]+\.git/, 
    via: [:get, :post, :head]
end
