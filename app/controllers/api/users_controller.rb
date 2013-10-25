class Api::UsersController < ApplicationController
before_filter :restrict_access
skip_before_filter :verify_authenticity_token

	  def index
		respond_to do |format|
      		format.json { head :ok }
    	end
  	end

  	def show
  		@user = User.find(params[:id])
  		respond_to do |format|
  			if not @user.nil?
  				format.json { render :file => "/api/users/show.json.erb", :content_type => 'application/json' }
  			end
  		end
  	end



    def currentuser
      @user = current_user
      respond_to do |format|
        format.json { render :file => "/api/users/currentuser.json.erb", :content_type => 'application/json' }
      end
    end

end
