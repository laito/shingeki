class Api::GcmsController < ApplicationController
before_filter :restrict_access
skip_before_filter :verify_authenticity_token
	def register
		@reg_id = params[:regid]
		@user = current_user
		if not @user.nil? and not @reg_id.nil?
			Gcmregistration.where("user_id = ?",@user.id).delete_all
			@gcmpair = Gcmregistration.where("user_id = ? and registration_id = ?",@user.id,@reg_id).first
			if @gcmpair.nil?
				@gcmpair = Gcmregistration.new
				@gcmpair.user_id = @user.id
				@gcmpair.registration_id = @reg_id
				@gcmpair.save
			end
			respond_to do |format|
      			format.json { head :ok }
    		end
		else
			respond_to do |format|
      			format.json { head :forbidden }
    		end
		end
	end
end
