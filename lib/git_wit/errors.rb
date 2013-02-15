module GitWit
  class NotFoundError < Exception; end
  class ForbiddenError < Exception; end
  class UnauthorizedError < Exception; end
  class GitError < Exception; end
end