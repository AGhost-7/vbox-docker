#!/usr/bin/env bash

set -eo pipefail

script_source="${BASH_SOURCE[@]}"
if [ -L "$script_source" ]; then
	script_source="$(readlink "$script_source")"
fi
cd "$(dirname "$script_source")"

case "$1" in
	ssh)
		ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i .data/key -p 2222 root@localhost
		;;
	start)
		ansible-playbook -i localhost, ./start-vm.yml
		ansible-playbook -i localhost, ./start-docker.yml
		;;
	stop)
		VBoxManage controlvm "$(cat .data/name)" poweroff
		;;
	remove)
		ansible-playbook -i localhost, ./remove.yml
		;;
	*)
		echo "Unknown command $1" >&2
		exit 1
		;;
esac
