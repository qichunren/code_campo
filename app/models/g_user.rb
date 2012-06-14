# encoding: utf-8
require "open-uri"

class GUser
  include Mongoid::Document
  include Mongoid::NumberId
  field :name
  field :email
  field :github_uid
  field :github_utype
  include Gravtastic
  gravtastic :rating => 'G', :size => 48, :secure => false
  field :avatar_url
  field :gravatar_id

  field :created_at, :type => DateTime
  field :sync_at, :type => DateTime
  field :last_actived_at, :type => DateTime # 最后活动时间

  field :oauth_access_token

  field :github_followers_count, :type => Integer
  field :github_following_count, :type => Integer
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
  has_many :events
  embeds_one :profile
  # before_save :build_profile
  has_and_belongs_to_many :following, class_name: 'GUser', inverse_of: :followers, autosave: true
  has_and_belongs_to_many :followers, class_name: 'GUser', inverse_of: :following
  def follow!(user)
    if self.name != user.name && !self.following.include?(user)
      self.following << user
    end
  end

  def unfollow!(user)
    self.following.delete(user)
  end

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

  @queue = :github_user_sync
  # TODO: 实现一个排队机制，如果已经在队列中，就不需要进队了
  def self.perform(github_login_id)
    a_guser = self.where(:name => github_login_id).first
    return if a_guser.nil?
    # return if a_guser.sync_at && (Time.now-a_guser.sync_at) >= 1.days
    a_guser.sync!
    a_guser.sync_event!
  end

  def async_sync!
    #if self.sync_at.nil? || (Time.now -self.sync_at) >= 1.days
      Resque.enqueue(GUser, self.name)
    #end
  end

  def sync!

      parsed_json = ActiveSupport::JSON.decode(open("https://api.github.com/users/#{self.name}").read)

    self.name = parsed_json["login"]
    self.email = parsed_json["email"]
    self.github_uid = parsed_json["id"]
    self.github_following_count = parsed_json["following"].to_i
    self.github_followers_count = parsed_json["followers"].to_i
    self.public_repos_count = parsed_json["public_repos"].to_i
    self.public_gists_count = parsed_json["public_gists"].to_i

    self.avatar_url = parsed_json["avatar_url"]
    self.gravatar_id = parsed_json["gravatar_id"]
    self.github_utype = parsed_json["type"]

    self.build_profile
    self.profile.location = parsed_json["location"]
    self.profile.url = parsed_json["blog"]
    self.profile.company = parsed_json["company"]
    self.profile.since_at = DateTime.parse parsed_json["created_at"]
    self.profile.description = parsed_json["bio"]
    self.profile.name = parsed_json["name"]
    self.profile.save

    self.sync_at = Time.now
    self.save!

    (self.github_following_count/100+1).times do |page|
      following_json = ActiveSupport::JSON.decode(open("https://api.github.com/users/#{self.name}/following?page=#{page}&per_page=100").read)
      following_json.each do |user_hash|
        user = GUser.where(:name => user_hash["login"]).first
        user = GUser.create(:name => user_hash["login"]) if user.nil?
        self.follow!(user)
      end
    end

  end

  def sync_event!
    event_json = ActiveSupport::JSON.decode(open("https://api.github.com/users/#{self.name}/events/public?per_page=100").read)
    event_json.each do |user_hash|
      event = Event.where("_id" => user_hash["id"]).first
      if event.nil?
        event = Event.new
        event._id = user_hash.delete('id')
        event.body = user_hash
        event.save!
      end
    end
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
    self.github_followers_count = omniauth_hash[:extra][:raw_info][:followers].to_i
    self.github_following_count = omniauth_hash[:extra][:raw_info][:following].to_i
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