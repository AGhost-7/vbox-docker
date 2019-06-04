#!/usr/bin/env bash

set -eo pipefail

export ANSIBLE_HOST_KEY_CHECKING=false

script_source="${BASH_SOURCE[@]}"
if [ -L "$script_source" ]; then
	script_source="$(readlink "$script_source")"
fi
cd "$(dirname "$script_source")"

ssh_private_key="$HOME/.local/share/vbox-docker/key"
ssh_user=vbox

vm_ssh() {
	ssh \
		-o UserKnownHostsFile=/dev/null \
		-o StrictHostKeyChecking=no \
		-i "$ssh_private_key" \
		-p 2223 \
		"$ssh_user@localhost" \
		$@
}

config_params() {
	if [ ! -f ~/.config/vbox-docker/config.yml ]; then
		echo ''
		return
	fi
	python3 <<-PYTHON
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

show-help() {
	cat - <<-HELP
	vbox-docker <subcommand>

	subcommands:

	  ssh - SSH into the docker host.

	  login - SSH into the machine and exec into the developmet container.

	  start - Boots up the VM.

	  stop - Stops the vm.

	  remove - Destroy the VM and remove any associated data.
	HELP
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
		VBoxManage controlvm "$(cat .$HOME/.local/share/vbox-docker/name)" poweroff
		if [ "$(uname)" == "Linux" ]; then
			umount -l "$HOME/workspace-vbox"
		else
			umount "$HOME/workspace-vbox"
		fi
		;;
	remove)
		ansible-playbook -i localhost, ./remove.yml
		;;
	help|--help|-h)
		show-help
		;;
	*)
		echo "Unknown command $1" >&2
		exit 1
		;;
esac
