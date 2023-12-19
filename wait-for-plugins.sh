#!/bin/bash -xe

echo "Waiting for plugins to be ready..."
while ! [ -f "/usr/src/redmine/files/plugins-are-ready" ]; do
	sleep 1
done

sed -i 's,http://deb.debian.org/debian,http://cloudfront.debian.net/debian,' /etc/apt/sources.list
while ! apt-get update; do sleep 5; done
apt-get install -qy make gcc libcurl4-openssl-dev patch
#gem install bundler
gem install bundler -v 2.4.22

for dir in /usr/src/redmine/plugins/*; do
        [ -d "$dir" ] || continue
        (cd "$dir"; bundle install)
done

# patch redmine 5 for zeitwerk shit
# Redmine issue #36519, also: https://www.redmine.org/boards/2/topics/67113?r=67330
#if ! [ -f /var/lock/hacked-plugin-loader.lock ]; then
#	( cd /usr/src/redmine && patch -p1 < /hack-plugin-loader.patch)
#	touch /var/lock/hacked-plugin-loader.lock
#fi

chown redmine:redmine /home/redmine -R

(cd /usr/src/redmine; bundle install)

# run plugin migrations
/docker-entrypoint.sh rake redmine:plugins RAILS_ENV=production
/docker-entrypoint.sh rake redmine:plugins:migrate RAILS_ENV=production

# start rails
/docker-entrypoint.sh "$@"
