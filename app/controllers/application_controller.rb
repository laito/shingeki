class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def create_event eventparams
    @user = current_user
    @event = eventparams
    if not @user.nil?
      @event[:user_id] = @user.id
      time = @event[:deadline]

      @event[:deadline] = Time.at(time.to_i)
      @event[:status] = 1 #Event is open
      @newevent = Event.new(@event)
      if @newevent.save
        return true
      else
        return false
      end
    end
  end


  def restrict_access
    authenticate_or_request_with_http_token do |token, options|
      ApiKey.exists?(access_token: token)
    end
  end

  def current_user
  	@current_user  = nil
    if not session[:user_id].blank?
    	@current_user ||= User.find(session[:user_id])
    end
    return @current_user
  end

end
