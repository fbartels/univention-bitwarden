app_name=bitwarden-rs
app_version=$(shell ./version.sh)

ucs_version=4.2

docker_name="mprasil/bitwarden:$(app_version)"

all: run-mounted
#build run

release: release-prepare release-update

release-prepare: add-version appcenter-docker-version

release-run: run-mounted

release-update: appcenter-files

add-version:
	if [ -z ${app_version} ] ; then echo "no target app_version specified"; exit 13; fi
	univention-appcenter-control new-version "$(ucs_version)/$(app_name)" "$(ucs_version)/$(app_name)=$(app_version)" || true

pull:
	if [ -z ${app_version} ] ; then echo "no target app_version specified"; exit 13; fi
	if [ `systemctl is-active docker` = "inactive" ] ; then sudo systemctl start docker; fi
	sudo docker pull $(docker_name)

run: pull clean
	sudo docker run -it \
	--name=$(app_name) $(docker_name)

run-mounted: pull clean
	sudo docker run -it \
	-v /var/lib/bitwarden_rs/:/data/ -p 9080:80 \
	--name=$(app_name) $(docker_name)

clean:
	sudo docker rm $(app_name) || true

appcenter-files: generate-docs
	univention-appcenter-control upload --noninteractive $(ucs_version)/$(app_name)=$(app_version) \
	configure_host inst preinst settings uinst \
	appcenter/README_EN appcenter/README_DE appcenter/README_UPDATE

appcenter-docker-version:
	univention-appcenter-control set --noninteractive $(ucs_version)/$(app_name)=$(app_version) \
	--json '{"DockerImage": $(docker_name)}'

generate-docs:
	pandoc appcenter/README_EN.md -t HTML -o appcenter/README_EN
	pandoc  --ascii appcenter/README_DE.md -t HTML -o appcenter/README_DE
	pandoc  --ascii appcenter/README_UPDATE.md -t HTML -o appcenter/README_UPDATE
	pandoc  --ascii appcenter/LongDescription.md -t HTML -o appcenter/LongDescription
	pandoc  --ascii appcenter/LongDescription_DE.md -t HTML -o appcenter/LongDescription_DE
	pandoc  --ascii README.md -t HTML -o README.html

#appcenter-app-description:
#	univention-appcenter-control set --noninteractive $(ucs_version)/$(app_name)=$(app_version) \
#	--json '{"LongDescription": "$(shell cat appcenter/LongDescription)"}'
#	# setting it for the german translation does not yet work
#	#univention-appcenter-control set --noninteractive $(ucs_version)/$(app_name)=$(app_version) \
#	#--json '{"\"l18n:de\".long_description": "This is a german test"}'

# Testing
test-clean:
	univention-app remove bitwarden-rs || true
	rm -rf /var/lib/bitwarden_rs

test-update-appcenter:
	univention-app update

test-install-0.10.0: test-update-appcenter
	# 0.10.0 will be the first official release
	univention-app install bitwarden-rs=0.10.0
	read wait

test-upgrade-latest: test-update-appcenter
	univention-app upgrade bitwarden-rs

test: test-clean test-install-0.10.0 test-upgrade-latest
