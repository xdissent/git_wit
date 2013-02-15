require "open3"
require_dependency "git_wit/application_controller"

module GitWit
  class GitController < ApplicationController

    ENV_KEEPERS = %w(REQUEST_METHOD QUERY_STRING REMOTE_ADDR SERVER_ADDR 
        SERVER_NAME SERVER_PORT CONTENT_TYPE)

    before_filter :authenticate, :authorize, :find_repository

    def service
      # Shell out to git-http-backend.
      out, err, status = Open3.capture3 git_env, GitWit.git_http_backend_path, 
        stdin_data: request.raw_post, binmode: true

      # Bail if the backend failed.
      raise GitError, err unless status.success?

      # Split headers and body from response.
      headers, body = out.split("\r\n\r\n", 2)
      
      # Convert CGI headers to HTTP headers.
      headers = Hash[headers.split("\r\n").map { |l| l.split(/\s*\:\s*/, 2) }]

      # Set status from header if given, otherwise it's a 200.
      self.status = headers.delete("Status").to_i if headers.key? "Status"

      # Set response body if given, otherwise empty string.
      self.response_body = body.presence || ""
    end

    private
    def git_env
      http_env = request.headers.select { |k, _| k.start_with? "HTTP_" }

      extras = {
        GIT_HTTP_EXPORT_ALL: "uknoit",
        GIT_PROJECT_ROOT: GitWit.repositories_path,
        PATH_INFO: "/#{params[:repository]}/#{params[:refs]}",
        REMOTE_USER: (user_attr(:username) || @username),
        GIT_COMMITTER_NAME: user_attr(:committer_name),
        GIT_COMMITTER_EMAIL: user_attr(:committer_email)
      }.reject { |_, v| v.nil? }.stringify_keys

      request.headers.dup.extract!(*ENV_KEEPERS).merge(http_env).merge(extras)
    end

    def authenticate
      # Disallow authentication over insecure protocol per configuration.
      raise ForbiddenError if !GitWit.insecure_auth \
        && request.authorization.present? && !request.ssl?

      # Authenticate user *ONLY IF CREDENTIALS ARE PROVIDED*
      @user = authenticate_with_http_basic do |username, password|
        @username = username
        GitWit.authenticate username, password
      end

      # Request credentials again if provided and no user was authenticated.
      if @user.nil? && request.authorization.present?
        request_http_basic_authentication GitWit.realm
      end
    end

    def authorize
      # Authorize for read-only operations
      if !write_op?
        raise UnauthorizedError unless GitWit.authorize_read @user, params[:repository]
        return
      end

      # Never allow anonymous write operations.
      if @user.nil?
        # Bail if we don't allow insecure auth and the protocol is insecure.
        raise ForbiddenError if !GitWit.insecure_auth && !request.ssl?
        # Request authentication credentials - either ssl or don't care.
        request_http_basic_authentication GitWit.realm
      end

      # Disallow write operations over insecure protocol per configuration.
      raise ForbiddenError if !GitWit.insecure_write && !request.ssl?

      # Authorize for write operations.
      raise UnauthorizedError unless GitWit.authorize_write @user, params[:repository]
    end

    # TODO: Sure about this?
    def write_op?
      str = "git-receive-pack"
      params[:service] == str || params[:refs].end_with?(str)
    end

    def find_repository
      repo_path = File.join GitWit.repositories_path, params[:repository]
      raise NotFoundError unless File.exist? repo_path
    end

    def user_attr(sym)
      try_user GitWit.config.send("#{sym}_attribute")
    end

    def try_user(sym_or_proc)
      return @user.try(sym_or_proc) if sym_or_proc.is_a? Symbol
      sym_or_proc.call(@user) if sym_or_proc.respond_to? :call
    end
  end
end
