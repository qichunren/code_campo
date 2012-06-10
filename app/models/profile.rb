class Profile
  include Mongoid::Document

  field :name
  field :url
  field :description
  field :company
  field :location
  field :since_at, :type => DateTime

  embedded_in :user, :class_name => "GUser"

  validates :name, :length => {:in => 3..20, :allow_blank => true}
  validates :url, :length => {:maximum => 100}
  validates :description, :length => {:maximum => 300}

  attr_accessible :name, :url, :description
end
