class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :lvl, :exp, :money, :hp
  
  has_many :habits, :dependent => :destroy
  has_many :rewards, :dependent => :destroy
  
  before_save :calculate_experience
  
  def calculate_experience
    
    self.money = 0 if self.money < 0
    
    self.exp = 0 if self.exp < 0
    if (self.exp > self.tnl)
      self.exp -= self.tnl # carry over
      self.lvl += 1
      self.hp = 50
    end
    
    if self.hp < 0
      self.hp = 50
      self.lvl = 1
      self.exp = 0
      self.money = 0
    end
  end

  #TODO figure this out. Google "RPG level up formula" or something
  def tnl
    # http://tibia.wikia.com/wiki/Formula
    50*self.lvl**2 - 150*self.lvl + 200
  end
  
  def as_json(options={})
    super(:only => [:email, :lvl, :exp, :money, :hp] )
  end
  
  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"]
      end
    end
  end
  
  def self.find_for_facebook_oauth(access_token, signed_in_resource=nil)
    data = access_token.extra.raw_info
    if user = self.find_by_email(data.email)
      user
    else # Create a user with a stub password. 
      self.create(:email => data.email, :password => Devise.friendly_token[0,20]) 
    end
  end
end
