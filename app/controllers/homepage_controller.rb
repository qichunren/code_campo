class HomepageController < ApplicationController
  before_filter :require_logined, :only => [:dashboard]
  def index
    @topics = Topic.active.limit(15)
    @users_count = GUser.count
    @topics_count = Topic.count
    @replies_count = Reply.count
  end

  def dashboard
    @following = current_user.following.desc("github_followers_count")
    # @events = Event.watch_event.all.to_a
    @rss = current_user.scribed_rsses.where(:_id => /WatchEvent/).desc("created_at")
  end
end
