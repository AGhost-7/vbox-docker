#!/usr/bin/env bash

set -e

mkdir -p "$HOME/.local/bin"

if [ ! -L "$HOME/.local/bin/vbox-docker" ]; then
	ln -s "$PWD/vbox-docker.sh" "$HOME/.local/bin/vbox-docker"
	echo 'Added vbox-docker command to ~/.local/bin'
fi
