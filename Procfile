web: rails s -p 3001
redis: redis-server
resque: bundle exec rake environment resque:work QUEUE=*
guard: bundle exec guard start --no-interactions