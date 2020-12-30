module HandsomeEngine
  class ApplicationController < ActionController::Base
    def index
      render json: {message: 'OK'}.to_json
    end
  end
end
