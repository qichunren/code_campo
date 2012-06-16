source 'http://rubygems.org'

gem 'rails', '3.2.3'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

gem 'bcrypt-ruby'
gem 'mongoid'
gem 'bson_ext'
gem 'haml'
gem 'twitter-bootstrap-rails', '2.0.3'
gem 'client_side_validations', :git => 'git://github.com/bcardarella/client_side_validations.git'
gem 'client_side_validations-mongoid'
gem 'kaminari'
gem 'gravtastic'
gem 'wmd-rails'
gem 'redcarpet'
gem 'http_accept_language'
gem 'rails-i18n'
gem 'jquery-rails'
gem 'highlight_js-rails'
gem 'rails-timeago', :git => 'git://github.com/jgraichen/rails-timeago.git'

gem "omniauth-github", "~> 1.0.1"

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
  gem 'therubyracer'
end

gem "resque"
gem "resque-loner"
gem "xml-simple", :require => "xmlsimple"

gem 'whenever', :require => false
gem 'capistrano', :require => false
gem 'rvm-capistrano', :require => false

group :development do
  gem "foreman"
  gem "guard"
  gem "guard-bundler", :git => "https://github.com/josin/guard-bundler.git", :ref => "e8f9e4bc0e9b798d17ffee3f0d5170e33eadf2a5"
  gem 'guard-test'
  gem 'growl' if RUBY_PLATFORM.include?("darwin")
end

group :test, :development do
  gem 'factory_girl_rails'
end
