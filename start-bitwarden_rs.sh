#!/bin/bash

set -e

# get latest tagged image
VERSION=$(git ls-remote --refs --tags https://github.com/dani-garcia/bitwarden_rs.git | sort -t '/' -k 3 -V | awk -F/ '{ print $3 }' | tail -1)

# create a link in the Univention portal
P="ucs/web/overview/entries/service"
APP="bitwarden-rs"
eval "$(ucr shell hostname domainname)"
ucr set \
	"$P/$APP"/description="Open source password management solutions for individuals, teams, and business organizations." \
	"$P/$APP"/label="Bitwarden" \
	"$P/$APP"/link="https://bitwarden.$hostname.$domainname/"

if [ ! -e ./env ]; then
	cat <<-EOF >"./env"
DOMAIN=https://bitwarden.$hostname.$domainname/
SIGNUPS_ALLOWED=true
EOF
fi

docker_name="mprasil/bitwarden:$VERSION"
docker pull $docker_name
docker rm -f $APP
docker run -d --name=$APP --restart=unless-stopped \
	-v /var/lib/bitwarden_rs/:/data/ \
	--env-file ./env \
	-p 127.0.0.1:9080:80 \
	$docker_name
