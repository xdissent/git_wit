require "open3"
require_dependency "git_wit/application_controller"

module GitWit
  class GitController < ApplicationController

    ENV_KEEPERS = %w(REQUEST_METHOD QUERY_STRING REMOTE_ADDR SERVER_ADDR 
        SERVER_NAME SERVER_PORT CONTENT_TYPE)

    before_filter :authenticate, :authorize, :find_repository

    def service
      # Shell out to git-http-backend.
      self.status, self.headers, self.response_body = run_shell
    end

    private
    def run_shell
      out, err, status = Open3.capture3 shell_env, shell_command, shell_opts
      raise GitError, err unless status.success?
      parse_cgi_response out 
    end

    def parse_cgi_response(cgi_response)
      cgi_headers, body = cgi_response.split("\r\n\r\n", 2)
      headers = parse_cgi_headers(cgi_headers)
      [parse_cgi_status(headers), headers, body]
    end

    def parse_cgi_headers(cgi_headers)
      Hash[cgi_headers.split("\r\n").map { |l| l.split(/\s*\:\s*/, 2) }]
    end

    def parse_cgi_status(cgi_headers)
      cgi_headers.key?("Status") ? cgi_headers.delete("Status").to_i : 200
    end

    def shell_env
      request.headers.dup.extract!(*ENV_KEEPERS).merge(http_env).merge(git_env)
    end

    def shell_command
      [GitWit.git_path, "http-backend"].join " "
    end

    def shell_opts
      {stdin_data: request.raw_post, binmode: true}
    end

    def git_env
      {
        GIT_HTTP_EXPORT_ALL: "uknoit",
        GIT_PROJECT_ROOT: GitWit.repositories_path,
        PATH_INFO: "/#{params[:repository]}/#{params[:refs] || params[:service]}",
        REMOTE_USER: (user_attr(:username) || @username),
        GIT_COMMITTER_NAME: user_attr(:name),
        GIT_COMMITTER_EMAIL: user_attr(:email)
      }.reject { |_, v| v.nil? }.stringify_keys
    end

    def http_env
      request.headers.select { |k, _| k.start_with? "HTTP_" }
    end

    def authenticate
      # Disallow authentication over insecure protocol per configuration.
      raise ForbiddenError if !GitWit.insecure_auth \
        && request.authorization.present? && !request.ssl?

      # Authenticate user *ONLY IF CREDENTIALS ARE PROVIDED*
      @user = authenticate_with_http_basic do |username, password|
        @username = username
        user = GitWit.user_for_authentication username
        user if GitWit.authenticate user, password
      end

      # Request credentials again if provided and no user was authenticated.
      if !@user.present? && request.authorization.present?
        request_http_basic_authentication_if_allowed
      end
    end

    def request_http_basic_authentication_if_allowed
      raise ForbiddenError if !GitWit.insecure_auth && !request.ssl?
      request_http_basic_authentication GitWit.realm
    end

    def authorize
      write_op? ? authorize_write : authorize_read
    end

    def authorize_write
      # Never allow anonymous write operations.
      return request_http_basic_authentication_if_allowed unless @user.present?

      # Disallow write operations over insecure protocol per configuration.
      raise ForbiddenError if !GitWit.insecure_write && !request.ssl?

      # Authorize for write operations.
      raise UnauthorizedError unless GitWit.authorize_write @user, params[:repository]
    end

    def authorize_read
      return true if GitWit.authorize_read(@user, params[:repository])
      raise UnauthorizedError if @user.present?
      request_http_basic_authentication_if_allowed
    end

    # TODO: Sure about this?
    def write_op?
      params[:service] == "git-receive-pack"
    end

    def find_repository
      repo_path = File.join GitWit.repositories_path, params[:repository]
      raise NotFoundError unless File.exist? repo_path
    end

    def user_attr(sym)
      try_user GitWit.send("#{sym}_attribute")
    end

    def try_user(sym_or_proc)
      return sym_or_proc.call(@user) if sym_or_proc.respond_to? :call
      if sym_or_proc.is_a?(Symbol) && @user.respond_to?(sym_or_proc)
        @user.try(sym_or_proc)
      end
    end
  end
end
