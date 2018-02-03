web: bundle exec puma -t 3:3 -p ${PORT:-3000} -e ${RACK_ENV:-development}
rpush: bundle exec rpush start -e $RACK_ENV -f
worker: rake jobs:work

release: rake db:migrate
