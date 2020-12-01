#!/bin/bash -ex

function install_from_github() {
	local repo="$1" bundler="$2"
	read username reponame <<<"${repo/\// }"
	[ -d "$reponame" ] && rm -rf $reponame
	(
		set -eo pipefail
		curl -sfL -D/dev/stderr https://api.github.com/repos/"$repo"/tarball | tar -zx --xform="s,$username-$reponame-[[:alnum:]]*,$reponame,"
		cd "$reponame"
		[ -n "$bundler" ] && rm -f Gemfile.lock && bundle
		exit 0
	)
}

rm -f /redmine/files/plugins-are-ready
cd /redmine/plugins

install_from_github skokhanovskiy/redmine_omniauth_google yes

install_from_github dergachev/redmine_git_remote
mkdir -p redmine_git_remote/repos
chown 999:999 redmine_git_remote/repos

install_from_github woblavobla/redmine_changeauthor

install_from_github two-pack/redmine_auto_assign_group

install_from_github haru/redmine_code_review

install_from_github speedy32129/time_logger

install_from_github martin-denizet/redmine_custom_css

[ -f /etc/redmine-compose/plugins ] && . /etc/redmine-compose/plugins
[ -d /etc/redmine-compose/plugins.d ] && for file in /etc/redmine-compose/plugins.d/*; do . "$file"; done

touch /redmine/files/plugins-are-ready
sleep 10 # wait for a bit before finishing - if we hit a restart loop, dont hammer github
