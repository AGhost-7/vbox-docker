#!/usr/bin/env bash

set -eo pipefail

script_source="${BASH_SOURCE[@]}"
if [ -L "$script_source" ]; then
	script_source="$(readlink "$script_source")"
fi
cd "$(dirname "$script_source")"

vm_ssh() {
	ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i .data/key -p 2222 root@localhost $@
}

case "$1" in
	ssh)
		vm_ssh
		;;
	login)
		vm_ssh -t docker exec -ti development_environment tmux new -A -s 0
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
