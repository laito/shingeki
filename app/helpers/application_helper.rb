module ApplicationHelper

  def current_user
  	@current_user  = nil
    if not session[:user_id].blank?
    	@current_user ||= User.find(session[:user_id])
    end
    return @current_user
  end
end
