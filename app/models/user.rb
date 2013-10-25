class User < ActiveRecord::Base


  has_many :gcmregistration
  has_one :api_key
  has_many :event
  

  
  def name
    if first_name.nil?
      return email
    else
    return first_name+" "+last_name
  end
  
  end
end
