require 'open-uri'

class AuthController < ApplicationController
  def facebook
    my_redirect_uri = "http://localhost:3000/auth/facebook"
    my_app_id = ""
    my_app_secret = ""
    users_code = params[:code]
    
    uri = "https://graph.facebook.com/oauth/access_token?client_id=#{my_app_id}&redirect_uri=#{my_redirect_uri}&client_secret=#{my_app_secret}&code=#{users_code}"
    
    response = open(uri).read
    
    token = response.split("&").first.split("=").last
    
    user = User.find(session[:user_id])
    user.facebook_access_token = token
    user.save
    
    if user.facebook_access_token
      friends_url = "https://graph.facebook.com/me/friends?fields=name,location&access_token=#{user.facebook_access_token}"
      response = open(friends_url).read
      json = JSON.parse(response)
      friends = json["data"]
      friends.each do |friend|
        if friend["location"] && friend["location"]["name"]
          user.friends.create name: friend["name"], location: friend["location"]["name"], facebook_id: friend["id"]
        end
      end
    end
    
    redirect_to user
  end
end








