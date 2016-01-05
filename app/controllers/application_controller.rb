class ApplicationController < ActionController::API

def nothing
    render json: '{}', content_type: 'application/json'
end

end
