FactoryGirl.define do
  factory :user, :class => GUser do
    sequence(:name){|n| "name#{n}" }
    sequence(:email){|n| "email#{n}@codecampo.com" }
    sequence(:oauth_access_token) {|n| "oauth_access_#{n}_token" }
    sequence(:avatar_url) {|n| "https://github.com/#{n}.png" }
    github_followers_count 0
    github_following_count 0
    public_repos_count 0
    public_gists_count 0
    profile { FactoryGirl.build(:profile) }
  end
end
