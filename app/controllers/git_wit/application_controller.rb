module GitWit
  class ApplicationController < ActionController::Metal
    include AbstractController::Callbacks
    include ActionController::HttpAuthentication::Basic::ControllerMethods
  end
end
