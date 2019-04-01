#!/usr/bin/env bash

set -eo pipefail

export ANSIBLE_HOST_KEY_CHECKING=false

script_source="${BASH_SOURCE[@]}"
if [ -L "$script_source" ]; then
	script_source="$(readlink "$script_source")"
fi
cd "$(dirname "$script_source")"

ssh_user=vbox
vm_ssh() {
	ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i .data/key -p 2223 "$ssh_user@localhost" $@
}

config_params() {
	if [ ! -f ~/.config/vbox-docker/config.yml ]; then
		echo ''
		return
	fi
	`which python python3` <<-PYTHON
	from __future__ import print_function
	import yaml
	from os import path, environ
	with open(path.join(environ['HOME'], '.config/vbox-docker/config.yml')) as file:
	  config = yaml.safe_load(file)
	  parts = []
	  for key in ('vm_cpus', 'vm_memory', 'container_image', 'nfs_client_workspace'):
	    if key in config:
	      print('-e {}="{}" '.format(key, config[key]), end='')
	PYTHON
}

case "$1" in
	ssh)
		if [ "$2" ]; then
			ssh_user="$2"
		fi
		vm_ssh
		;;
	login)
		vm_ssh -t docker exec -ti development_environment tmux new -A -s 0
		;;
	start)
		ansible-playbook -i inventory $(config_params) ./start.yml
		;;
	stop)
		VBoxManage controlvm "$(cat .data/name)" poweroff
		if [ "$(uname)" == "Linux" ]; then
			umount -l "$HOME/workspace-vbox"
		else
			umount "$HOME/workspace-vbox"
		fi
		;;
	remove)
		ansible-playbook -i localhost, ./remove.yml
		;;
	*)
		echo "Unknown command $1" >&2
		exit 1
		;;
esac
