class Api::SigninsController < ApplicationController
before_filter :restrict_access
skip_before_filter :verify_authenticity_token
require 'net/http'

	def create
		# Use Google's Token Verification scheme to extract the user's email address
		token = params[:token]
		url = URI.parse("https://www.googleapis.com/oauth2/v1/userinfo?access_token="+token)
		req = Net::HTTP::Get.new(URI.encode(url.to_s))
		http = Net::HTTP.new(url.host, url.port)
		http.use_ssl = true
		http.verify_mode = nil
		#https.ca_file = "lib/assets/cacert.pm"
		resp = nil
		data = nil
		http.start do |h|
  			resp, data = h.request req
		end
		data = JSON.parse(resp.body)

		if resp.code == "200"
		  # Find a user
			@user = User.where(:email => data["email"].downcase).first

		   		if @user.nil?
		    	#Create a user with the data we just got back
		    		firstname = data["given_name"]
		    		surname = data["family_name"]
		    		email = data["email"]
		    		domain = data["hd"]
		    		puts data["hd"]
		    		if data["hd"].eql? "iiitd.ac.in"
		    			@user = User.new(:first_name => firstname, :last_name => surname, :email => email, :access_token => token)
		    			@user.save
		    			respond_to do |format|
							format.json { head :ok}
						end
					else
						respond_to do |format|
							format.json { head :forbidden}
						end
					end

				else
					session[:user_id] = @user.id
					respond_to do |format|
						format.json { head :ok}
					end
		  		end
			else
		 # Bad or revoked token 
		 	respond_to do |format|
				format.json { head :forbidden}
			end
		end
	end
end