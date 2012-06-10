# encoding: utf-8
class GUser
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Mongoid::NumberId
  field :name
  field :email
  include Gravtastic
  gravtastic :rating => 'G', :size => 48, :secure => false
  field :avatar_url

  field :created_at, :type => DateTime
  field :last_actived_at, :type => DateTime # 最后活动时间

  field :oauth_access_token
  field :followers_count, :type => Integer
  field :following_count, :type => Integer
  field :public_repos_count, :type => Integer
  field :public_gists_count, :type => Integer

  field :locale, :default => I18n.locale.to_s


  has_many :notifications, :class_name => 'Notification::Base', :dependent => :delete, :foreign_key => "user_id" do
    def has_unread?
      unread.count > 0
    end
  end

  has_many :topics, :dependent => :destroy, :foreign_key => "user_id"
  has_many :replies, :dependent => :destroy, :foreign_key => "user_id"
  embeds_one :profile
  # before_save :build_profile

  def admin?
    APP_CONFIG['admin_emails'].include?(self.email)
  end

  def to_param
    name.to_s
  end

  def screen_name
    (profile.name.blank? || profile.name == name) ? name : "#{name}(#{profile.name})"
  end

  def github_url
    "https://github.com/#{name.to_s}"
  end


  def self.from_oauth omniauth_hash
    guser = GUser.where(:name => omniauth_hash[:extra][:raw_info][:login]).first
    if guser
      guser.sync_from_oauth omniauth_hash
      guser.save
    else
      guser = create_from_oauth omniauth_hash
    end
    guser
  end

  def self.create_from_oauth omniauth_hash
    guser = GUser.new
    guser.sync_from_oauth omniauth_hash
    guser.save
    guser
  end

  def sync_from_oauth omniauth_hash
    self.name = omniauth_hash[:extra][:raw_info][:login]
    self.email = omniauth_hash[:info][:email]
    self.oauth_access_token = omniauth_hash[:credentials][:token]
    self.avatar_url = omniauth_hash[:extra][:raw_info][:avatar_url]
    self.followers_count = omniauth_hash[:extra][:raw_info][:followers].to_i
    self.following_count = omniauth_hash[:extra][:raw_info][:following].to_i
    self.public_repos_count = omniauth_hash[:extra][:raw_info][:public_repos].to_i
    self.public_gists_count = omniauth_hash[:extra][:raw_info][:public_gists].to_i
    self.build_profile if self.profile.nil?

    self.profile.name = omniauth_hash[:info][:name]
    self.profile.company = omniauth_hash[:extra][:raw_info][:company]
    self.profile.location = omniauth_hash[:extra][:raw_info][:location]
    self.profile.url = omniauth_hash[:info][:urls][:Blog]
    self.profile.description = omniauth_hash[:extra][:raw_info][:bio]
    self.profile.since_at = omniauth_hash[:extra][:raw_info][:created_at]
    self.profile.save
  end

  def read_notifications(notifications)
    unread_ids = notifications.find_all{|notification| !notification.read?}.map(&:_id)
    if unread_ids.any?
      Notification::Base.where({
        :user_id => id,
        :_id.in  => unread_ids,
        :read    => false
      }).update_all(:read => true)
    end
  end

  def mark_all_notifications_as_read
    Notification::Base.where({
      :user_id => id,
      :read    => false
    }).update_all(:read => true)
  end

end