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
		ansible-playbook -i inventory ./start.yml
		;;
	stop)
		VBoxManage controlvm "$(cat .data/name)" poweroff
		;;
	*)
		echo "Unknown command $1" >&2
		exit 1
		;;
esac
