module GitWit
  class Engine < ::Rails::Engine
    isolate_namespace GitWit

    config.action_dispatch.rescue_responses.merge!(
      "GitWit::NotFoundError"     => :not_found,
      "GitWit::ForbiddenError"    => :forbidden,
      "GitWit::UnauthorizedError" => :unauthorized,
      "GitWit::GitError"          => :internal_server_error
    )
  end
end
