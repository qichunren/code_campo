class Event
  include Mongoid::Document
  field :_id, :type => String
  field :body, :type => Hash
  scope :watch_event, where("body.type" => "WatchEvent").desc("_id")

  def actor
    self.body['actor']['login']
  end

  def actor_url
    self.body['actor']['url']
  end

  def actor_avatar_url
    self.body['actor']['avatar_url']
  end

  def created_at
    self.body['created_at']
  end

end