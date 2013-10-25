class SigninsController < ApplicationController
  skip_before_filter :verify_authenticity_token


  def calendarauth
     code = params[:code]
     @user = current_user
     if not code.nil? and not @user.nil? #User accepted the request
        url = "https://accounts.google.com/o/oauth2/token"
        options = {
            body: {
              client_id: '456728129725.apps.googleusercontent.com',
              client_secret: 'coYjS7KXnCD2Wjz7ydmCczYr',
              code: code,
              redirect_uri: 'http://localhost:3000/auth/google_oauth2_calendarapi/callback',
              grant_type: 'authorization_code'
            },
            headers: {
              'Content-Type' => 'application/x-www-form-urlencoded'
            }
          }
          @response = HTTParty.post('https://accounts.google.com/o/oauth2/token', options)    #We create a request to be sent to Gooogle to update the access token of the use
          access_token = @response["access_token"]
          refresh_token = @response["refresh_token"]
          @user.calendar_access_token = access_token
          @user.calendar_refresh_token = refresh_token
          @user.save
          redirect_to "/user/calendar" and return
     end
     redirect_to "/" and return
  end

  def oauth_failure
    redirect_to "/"
  end

  def new
    redirect_to "/auth/google_oauth2"
  end

  def calnew
    @user = current_user
    if not @user.nil?
      #redirect_to "https://accounts.google.com/o/oauth2/auth?scope=https://www.googleapis.com/auth/calendar&redirect_uri=http://localhost/auth/google_oauth2_calendarapi/callback&response_type=code&client_id=456728129725.apps.googleusercontent.com"
      redirect_to "https://accounts.google.com/o/oauth2/auth?scope=https://www.googleapis.com/auth/calendar&response_type=code&access_type=offline&redirect_uri=http://localhost:3000/auth/google_oauth2_calendarapi/callback&client_id=456728129725.apps.googleusercontent.com&hl=en&from_login=1&pli=1"
    else
      redirect_to "/"
    end
  end



    def create
      if params[:provider].eql? "google_oauth2_calendarapi"
        calendarauth()
        return
      end
      begin
        domainerror = false
        auth = request.env["omniauth.auth"]
        usermail = auth["info"]["email"]
        firstname = auth["info"]["first_name"]
        lastname = auth["info"]["last_name"]
        user = User.where("LOWER(email) = ?",usermail.downcase).first
        if not user.nil?
          #User already exists in the db
          #if user.access_token.blank? or user.expires.blank? or user.uid.blank? or user.provider.blank?#First time using oauth2
            user.update_attributes!(
              :provider => auth["provider"], 
              :uid => auth["uid"],
              :refresh_token => auth["credentials"]["refresh_token"],
              :access_token => auth["credentials"]["token"],
              :expires => DateTime.strptime(auth["credentials"]["expires_at"].to_s,'%s'),
               :first_name => firstname,
               :last_name => lastname
              )
            user.save!
          #end
          session[:user_id] = user.id
          session[:superuser] = false
          if not user.has_badge(Merit::Badge.find(26))  #Busy Bee Badge!
            @deadlinecount = 0 
            user.course.each do |c|
              c.deadline.each do |d|
                if (d.endDateTime - Time.new) <= 7*24*60*60 and (d.endDateTime - Time.new) >= 0
                  @deadlinecount +=1
                end
              end
            end

            if @deadlinecount >= 5 
              user.add_badge(26)
            end
          end

          if not user.birthday.eql? nil 
            if user.birthday.month == Time.new.month and user.birthday.day == Time.new.day and not user.has_badge(Merit::Badge.find(7))
              user.add_badge(7)
            end
          end
          firsttime = false
          if user.notification_prefs[:loggedin].blank?
            user.notification_prefs[:loggedin] = 0
            firsttime = true
          end
          user.notification_prefs[:loggedin] += 1
          if not user.has_badge(Merit::Badge.find(3))
            if not user.birthday.eql? nil and user.avatar.exists?         
              user.add_badge(3)
            end
          end
          if user.notification_prefs[:loggedin] == 50
            if not user.has_badge(Merit::Badge.find(15))
              user.add_badge(15)
            end
          end
          user.save!
          if user.usertype.eql? "I" and firsttime
            redirect_to(new_path) and return
          else
            redirect_to(home_path) and return
          end
        else
          #User not found
          domain = usermail.split("@").last
          if not domain.eql? "iiitd.ac.in"
            domainerror = true
            redirect_to(domainnotallowed_path) and return#Domain not allowed
          end
          #User is a valid iiitd account but not registered yet
          user = User.create!(
            :provider => auth["provider"], 
            :uid => auth["uid"],
            :refresh_token => auth["credentials"]["refresh_token"],
            :access_token => auth["credentials"]["token"],
            :expires => auth["credentials"]["expires_at"],
            :semester_id => 1,
            :level => 1,
            :updated_at => Time.now,
            :created_at => Time.now,
            :institute_id => 1,
            :email => usermail,
            :first_name => firstname.split(' ').map(&:capitalize).join(' '),
            :last_name => lastname.split(' ').map(&:capitalize).join(' '))
          #Set default values for user notification settings
          session[:user_id] = user.id
          session[:superuser] = false
          user.notification_prefs[:notif_deadline] = '0'
          user.notification_prefs[:notif_resource] = '0'
          user.notification_prefs[:notif_reply] = '1'
          user.notification_prefs[:notif_badgeorlevel] = '1'
          user.notification_prefs[:notif_instructor] = '1'
          user.notification_prefs[:loggedin] = 1
          user.save
          redirect_to "/" and return
        end
      rescue OmniAuth::Strategies::OAuth2::CallbackError
        redirect_to "/" and return
      end
    end

    def create2

      if openid = request.env[Rack::OpenID::RESPONSE]
        if openid.status.eql? :cancel
          redirect_to "/" and return
        end
        case openid.status
        when :success

          domainerror = false
          ax = OpenID::AX::FetchResponse.from_success_response(openid)

          #Make sure the email is a valid IIIT-Delhi account
          domain = ax.get_single('http://axschema.org/contact/email').split("@").last
          if(false and not domain.eql? "iiitd.ac.in")
            domainerror = true
            redirect_to(domainnotallowed_path) #Domain not allowed
          else
            #Right now we put the placeholder default values for institute and semester values.
            #To be implemented: A page to add institute and semesters for that institute.
            if Semester.count.eql? 0
              @institute = Institute.create(:name => 'IIIT-Delhi',:website => 'http://www.iiitd.ac.in')
              Semester.create(:season => 'Monsoon', :year => 2013, :institute_id => 1)
              @institute.update_attributes(:current_semester_id => 1)
            end

            user = User.where(:identifier_url => openid.display_identifier).first
            new_user = false
            if user.blank?
              new_user = true
              if(not domain.eql? "iiitd.ac.in")
                emailid = ax.get_single('http://axschema.org/contact/email')
                user = User.where("LOWER(email) = ?",emailid.downcase).first#find_by_email(emailid)
                if user.nil?
                  domainerror = true
                  redirect_to(domainnotallowed_path)
                end
              end
            end
            if not domainerror
            emailid = ax.get_single('http://axschema.org/contact/email')
            user = User.find_by_email(emailid)
            if not user.nil?
              user.update_attributes(
            :identifier_url => openid.display_identifier,
            :semester_id => 1,
            :updated_at => Time.now,
            :created_at => Time.now,
            :institute_id => 1,
            :email => ax.get_single('http://axschema.org/contact/email'),
            :first_name => ax.get_single('http://axschema.org/namePerson/first').split(' ').map(&:capitalize).join(' '),
            :last_name => ax.get_single('http://axschema.org/namePerson/last').split(' ').map(&:capitalize).join(' ')
                )
            else
            user ||= User.create!(:identifier_url => openid.display_identifier,
            :semester_id => 1,
            :level => 1,
            :updated_at => Time.now,
            :created_at => Time.now,
            :institute_id => 1,
            :email => ax.get_single('http://axschema.org/contact/email'),
            :first_name => ax.get_single('http://axschema.org/namePerson/first').split(' ').map(&:capitalize).join(' '),
            :last_name => ax.get_single('http://axschema.org/namePerson/last').split(' ').map(&:capitalize).join(' '))
            end
            session[:user_id] = user.id
            session[:superuser] = false
            if new_user
              #if user.usertype.eql? "I"
              #  user.add_badge(3)
              #end
              user.notification_prefs[:notif_deadline] = '0'
              user.notification_prefs[:notif_resource] = '0'
              user.notification_prefs[:notif_reply] = '1'
              user.notification_prefs[:notif_badgeorlevel] = '1'
              user.notification_prefs[:notif_instructor] = '1'
              user.notification_prefs[:loggedin] = 1
              user.save
              #user.add_badge(2)
            else

              if not user.has_badge(Merit::Badge.find(26))  #Busy Bee Badge!
              @deadlinecount = 0 
              user.course.each do |c|
                c.deadline.each do |d|
                if (d.endDateTime - Time.new) <= 7*24*60*60 and (d.endDateTime - Time.new) >= 0
                  @deadlinecount +=1
                end
              end
              end

              if @deadlinecount >= 5 

                user.add_badge(26)
              end

              end


               if not user.birthday.eql? nil 
                if user.birthday.month == Time.new.month and user.birthday.day == Time.new.day and not user.has_badge(Merit::Badge.find(7))
                user.add_badge(7)
              end
            end
              if user.notification_prefs[:loggedin].blank?
                user.notification_prefs[:loggedin] = 1
              end
              user.notification_prefs[:loggedin] += 1
              if not user.has_badge(Merit::Badge.find(3))
                  if not user.birthday.eql? nil and user.avatar.exists?         
                    user.add_badge(3)
                  end
               end
              if user.notification_prefs[:loggedin] == 50
                if not user.has_badge(Merit::Badge.find(15))
                  user.add_badge(15)
               end
              end
              user.save
            end
            redirect_to(home_path)
            end
          end
        when :failure
          redirect_to (signin_path)
          #render :action => 'problem'
        end
      else
        redirect_to new_signin_path
      end
    end

    def destroy
      session[:user_id] = nil
      session[:superuser] = nil
      redirect_to home_path
    end
  end
