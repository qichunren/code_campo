task :fetch_events => :environment do
  users = GUser.chinese
  Rails.logger.info "Fetch events:current activity #{Activity.count}"
  Activity.fetch_from users
  Rails.logger.info "Fetch events:current activity #{Activity.count}"
end

task :sync_users => :environment do
  Rails.logger.info "sync users: user count #{GUser.count}"
  GUser.chinese.each do |user|
    user.async_sync!
  end
  Rails.logger.info "sync users: user count #{GUser.count}"
  GUser.make_chines_githubors!
end

task :mark_chinese_user => :environment do
  GUser.make_chines_githubors!
end