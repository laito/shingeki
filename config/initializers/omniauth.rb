 Rails.application.config.middleware.use OmniAuth::Builder do
   provider :google_oauth2, "83003395981-d5so1015ogdlrhbg3mtappc91nh3hc56.apps.googleusercontent.com", "5H0A8affzk11pc2f5grNSn4P", {
     access_type: 'offline',
    #client_options: {ssl: {ca_file: Rails.root.join('lib/assets/cacert.pem').to_s}},
    client_options: {ssl: { :verify => false}},
     scope: 'https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile',
     redirect_uri:'http://localhost/auth/google_oauth2/callback'
   }
end
OmniAuth.config.on_failure = SigninsController.action(:oauth_failure)
