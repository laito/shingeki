class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  require 'gcm'
  protect_from_forgery with: :exception


  def notify text id registration_ids
    gcm = GCM.new("AIzaSyAjjegzxOGVfz9YKl7_hTcYFnm4CP-i0tk")
    options = {data: {text: text, type: "event", id: id}, collapse_key: "newevent"}
    response = gcm.send_notification(registration_ids, options)
  end


  def create_event eventparams
    gcm = GCM.new("AIzaSyAjjegzxOGVfz9YKl7_hTcYFnm4CP-i0tk")
    @user = current_user
    @event = eventparams
    @users = User.all
    registration_ids = []
    @users.each do |u|
      reg_ids = user.gcmregistration
      reg_ids = reg_ids.map{|x| x.registration_id}
      registration_ids = registration_ids.concat(reg_ids)
    end
    if not @user.nil?
      @event[:user_id] = @user.id
      time = @event[:deadline]
      @event[:deadline] = Time.at(time.to_i)
      @event[:status] = 1 #Event is open
      @newevent = Event.new(@event)
      if @newevent.save
        text = @user.name+" wants to "+@newevent.title
        options = {data: {text: text, type: "event", id: @newevent.id}, collapse_key: "newevent"}
        response = gcm.send_notification(registration_ids, options)
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
