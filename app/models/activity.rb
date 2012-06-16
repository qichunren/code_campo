class Activity
  include Mongoid::Document
  field :_id, :type => String
  field :created_at, :type => DateTime
  field :link
  field :text
  field :actor
  field :actor_avatar_url

  # scope :watch_event, where(:_id => /WatchEvent/)
  scope :useful, where(:_id.in => [/PullRequestEvent/, /WatchEvent/])

  def self.fetch_from users
    users.each do |user|
      atom_url = "https://github.com/#{user.name}.atom"

      begin

        rss_hash = XmlSimple.xml_in open(atom_url).read
        rss_hash['entry'].each do |entry|
          next if self.where("id" => entry['id'].first).first.present?
          create(:id => entry['id'].first,
                 :created_at => DateTime.parse(entry['published'].first),
                 :link => entry['link'].first['href'],
                 :text => entry['title'].first['content'],
                 :actor => entry['author'].first['name'].first,
                 :actor_avatar_url => entry['thumbnail'].first['url']
                )
        end if rss_hash['entry'].present?
      rescue Exception => error
        Rails.logger.error "Faild to fetch atom from user #{user.name.to_s}.[#{error.message}]"
      end
    end
  end

end