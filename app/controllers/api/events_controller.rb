class Api::EventsController < ApplicationController
before_filter :restrict_access
skip_before_filter :verify_authenticity_token

require 'gcm'


 	def event_params
   		 params.require(:event).permit(:title, :description, :deadline, :tip, :eventtype)
   	end

	def create
		respond_to do |format|
		    created = create_event(event_params)
		    if created
		      	format.json { render :file => "/api/events/created.json.erb", :content_type => 'application/json' }
		    else
		      	format.json { render :file => "/api/events/error.json.erb", :content_type => 'application/json' }
		    end
		end
	end

    #Accept someone's event
    def accept
    	@user = current_user
    	if not @user.nil?
    		eventid = params[:id]
    		@event = Event.find(eventid)
    		if not @event.nil?
    			if @event.status == 1 #Can only accept open events
    				@event.acceptor_id = @user.id
    				@event.status = 0
    				@event.save
                    registration_ids = []
                    reg_ids = @event.user.gcmregistration
                    reg_ids = reg_ids.map{|x| x.registration_id}
                    registration_ids = registration_ids.concat(reg_ids)
                    text = @user.name+" has accepted your request to "+@event.title
                    notify text @event.id registration_ids
                    respond_to do |format|
                        format.json { render :file => "/api/events/created.json.erb", :content_type => 'application/json' }
                    end
    			else
    				respond_to do |format|
		      			format.json { render :file => "/api/events/error.json.erb", :content_type => 'application/json' }
    				end
    			end
    		else
    			respond_to do |format|
		      		format.json { render :file => "/api/events/error.json.erb", :content_type => 'application/json' }
    			end
    		end
    	else
    		respond_to do |format|
		      	format.json { render :file => "/api/events/error.json.erb", :content_type => 'application/json' }
    		end
    	end
    end

    def optout
    	@user = current_user
    	if not @user.nil?
    		eventid = params[:id]
    		@event = Event.find(eventid)
    		if not @event.nil?
    			if @event.acceptor_id.eql? @user.id #Make sure we are opting out of our own accepted event
    				@event.status = 1
    				@event.acceptor_id = nil
    				@event.save
                    registration_ids = []
                    reg_ids = @event.user.gcmregistration
                    reg_ids = reg_ids.map{|x| x.registration_id}
                    registration_ids = registration_ids.concat(reg_ids)
                    text = @user.name+" has opted out of your request to "+@event.title
                    notify text @event.id registration_ids
                    respond_to do |format|
                        format.json { render :file => "/api/events/created.json.erb", :content_type => 'application/json' }
                    end
    			else
    				respond_to do |format|
		      			format.json { render :file => "/api/events/error.json.erb", :content_type => 'application/json' }
    				end
    			end
    		else
    			respond_to do |format|
		      		format.json { render :file => "/api/events/error.json.erb", :content_type => 'application/json' }
    			end
    		end
    	else
    		respond_to do |format|
		      	format.json { render :file => "/api/events/error.json.erb", :content_type => 'application/json' }
    		end
    	end
    end

    def cancel
    	@user = current_user
    	if not @user.nil?
    		eventid = params[:id]
    		@event = Event.find(eventid)
    		if not @event.nil?
    			if @event.user_id.eql? @user.id
    				@event.status = 0
    				@event.save
                    respond_to do |format|
                        format.json { render :file => "/api/events/created.json.erb", :content_type => 'application/json' }
                    end
    			else
    				respond_to do |format|
		      			format.json { render :file => "/api/events/error.json.erb", :content_type => 'application/json' }
    				end
    			end
    		else
    			respond_to do |format|
		      		format.json { render :file => "/api/events/error.json.erb", :content_type => 'application/json' }
    			end
    		end
    	else
    		respond_to do |format|
		      	format.json { render :file => "/api/events/error.json.erb", :content_type => 'application/json' }
    		end
    	end
    end

    def approved
    	@user = current_user
    	if not @user.nil?
    		eventid = params[:id]
    		@event = Event.find(eventid)
    		if not @event.nil?
    			if @event.user_id.eql? @user.id
    				@event.status = 2
    				@event.save
                    registration_ids = []
                    reg_ids = @user.gcmregistration
                    reg_ids = reg_ids.map{|x| x.registration_id}
                    registration_ids = registration_ids.concat(reg_ids)
                    text = @event.user.name+" thanked you!"
                    notify text @event.id registration_ids
                    respond_to do |format|
                        format.json { render :file => "/api/events/created.json.erb", :content_type => 'application/json' }
                    end
    				respond_to do |format|
		      			format.json { render :file => "/api/events/error.json.erb", :content_type => 'application/json' }
    				end
    			else
    				respond_to do |format|
		      			format.json { render :file => "/api/events/error.json.erb", :content_type => 'application/json' }
    				end
    			end
    		else
    			respond_to do |format|
		      		format.json { render :file => "/api/events/error.json.erb", :content_type => 'application/json' }
    			end
    		end
    	else
    		respond_to do |format|
		      	format.json { render :file => "/api/events/error.json.erb", :content_type => 'application/json' }
    		end
    	end
    end


	def show
		@user = current_user
		if not @user.nil?
			eventid = params[:id]
			@event = Event.find(eventid)
			if not @event.nil?
				respond_to do |format|
		      		format.json { render :file => "/api/events/show.json.erb", :content_type => 'application/json' }
    			end
    		else
    			respond_to do |format|
		      		format.json { render :file => "/api/events/error.json.erb", :content_type => 'application/json' }
    			end
			end
		else
			respond_to do |format|
		      	format.json { render :file => "/api/events/error.json.erb", :content_type => 'application/json' }
    		end
		end
	end

	def index
		@user = current_user
		type = params[:eventtype]
		status = params[:status]
		if not type.nil?
			indextype()
			return
		end
		if not status.nil?
			@eventlist = Event.where("status = ?",status)
		else
			@eventlist = Event.all
		end
		respond_to do |format|
		    if @user.nil?
		      	format.json { render :file => "/api/events/error.json.erb", :content_type => 'application/json' }
		    else
		      	format.json { render :file => "/api/events/eventlist.json.erb", :content_type => 'application/json' }
		    end
		end
	end

	def indextype
		@user = current_user
		type = params[:eventtype]
		status = params[:status]
		if not status.nil?
			@eventlist = Event.where("eventtype = ? and status = ?",type,status)
		else
			@eventlist = Event.where("eventtype = ?",type)
		end

		respond_to do |format|
		    if @user.nil?
		      	format.json { render :file => "/api/events/error.json.erb", :content_type => 'application/json' }
		    else
		      	format.json { render :file => "/api/events/eventlist.json.erb", :content_type => 'application/json' }
		    end
		end
	end

	def myevents
		@user = current_user
		@eventlist = @user.event
		respond_to do |format|
		    if @user.nil?
		      	format.json { render :file => "/api/events/error.json.erb", :content_type => 'application/json' }
		    else
		      	format.json { render :file => "/api/events/eventlist.json.erb", :content_type => 'application/json' }
		    end
		end
	end
end