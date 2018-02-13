web: bundle exec puma -C config/puma.rb
rpush: bundle exec rpush start -e $RACK_ENV -f
worker: rake jobs:work

release: rake db:migrate
