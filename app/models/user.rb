class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable

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
end
