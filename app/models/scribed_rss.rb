class ScribedRss
  include Mongoid::Document
  field :_id, :type => String
  field :created_at, :type => DateTime
  field :link
  field :text
  field :actor
  field :actor_avatar_url

  belongs_to :user, :class_name => 'GUser'

  def self.fetch(user)
    atom_url = "https://github.com/#{user.name}.private.atom?token=#{user.profile.private_atom_token}"
    rss_hash = XmlSimple.xml_in open(atom_url).read
    rss_hash['entry'].each do |entry|
      if self.where("id" => entry['id'].first).first.nil?
        create(:id => entry['id'].first,
               :created_at => DateTime.parse(entry['published'].first),
               :link => entry['link'].first['href'],
               :text => entry['title'].first['content'],
               :actor => entry['author'].first['name'].first,
               :actor_avatar_url => entry['thumbnail'].first['url'],
               :user => user
              )
      end
    end
  end


end