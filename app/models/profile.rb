class Profile
  include Mongoid::Document

  field :name # from github user profile
  field :true_name # set from local, not from github user profile
  field :url
  field :description
  field :company
  field :location
  field :since_at, :type => DateTime

  embedded_in :user, :class_name => "GUser"

  validates :name, :length => {:in => 3..20, :allow_blank => true}
  validates :url, :length => {:maximum => 100}
  validates :description, :length => {:maximum => 300}

  attr_accessible :name, :true_name, :url, :description
end
