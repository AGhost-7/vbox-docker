#!/usr/bin/env bash

set -e
set -x

# {{{ copypasta
# taken from:
# https://github.com/chef/bento/blob/master/packer_templates/ubuntu/scripts/cleanup.sh

dpkg --list \
  | awk '{ print $2 }' \
  | grep 'linux-headers' \
  | xargs apt-get -y purge

# Delete X11 libraries
apt-get -y purge libx11-data xauth libxmuu1 libxcb1 libx11-6 libxext6

# Delete obsolete networking
apt-get -y purge ppp pppconfig pppoeconf

# Delete oddities
apt-get -y purge popularity-contest installation-report command-not-found command-not-found-data friendly-recovery bash-completion fonts-ubuntu-font-family-console laptop-detect

# Exlude the files we don't need w/o uninstalling linux-firmware
echo "==> Setup dpkg excludes for linux-firmware"
cat <<_EOF_ | cat >> /etc/dpkg/dpkg.cfg.d/excludes
#BENTO-BEGIN
path-exclude=/lib/firmware/*
path-exclude=/usr/share/doc/linux-firmware/*
#BENTO-END
_EOF_

# Delete the massive firmware packages
rm -rf /lib/firmware/*
rm -rf /usr/share/doc/linux-firmware/*

apt-get -y autoremove;
apt-get -y clean;

# Remove caches
find /var/cache -type f -exec rm -rf {} \;

# delete any logs that have built up during the install
find /var/log/ -name *.log -exec rm -f {} \;

# }}}

# remove unused kernel images
(
	dpkg --get-selections | \
		grep 'linux-image-.*-generic' | \
		grep -v `uname -r` | \
		xargs apt-get purge -y
) || true
# apt fails to fully remove the old kernel
find /lib/modules -maxdepth 1 -mindepth 1 -not -name `uname -r` -exec rm -rf {} \;

# remove even more unused packages
apt-get purge -y snapd lxd vim vim-common vim-tiny vim-runtime geoip-database git git-man byobu screen

# get rid of docs
apt-get purge -y man-db
cat - > /etc/dpkg/dpkg.cfg.d/no-doc <<CONFIG
path-exclude=/usr/share/doc/*
path-exclude=/usr/share/locale/*/LC_MESSAGES/*.mo
path-exclude=/usr/share/man/*
CONFIG
rm -rf /usr/share/doc/*
rm -rf /usr/share/locale/*
rm -rf /usr/share/man/*

# try to remove even more logs
rm -rf /var/log/installer
journalctl --flush --rotate
journalctl --vacuum-size=1K

systemctl stop apt-daily.timer
systemctl stop apt-daily-upgrade.timer
systemctl disable apt-daily.timer
systemctl disable apt-daily-upgrade.timer

# apt clean doesnt seem to be cleaning up much...
rm -rf /var/lib/apt/lists/*
apt-get clean -y

# {{{ more copypasta
# taken from: https://github.com/chef/bento/blob/master/packer_templates/_common/minimize.sh

# Whiteout root
count=$(df --sync -kP / | tail -n1  | awk -F ' ' '{print $4}')
count=$(($count-1))
dd if=/dev/zero of=/tmp/whitespace bs=1M count=$count || echo "dd exit code $? is suppressed";
rm /tmp/whitespace

# Whiteout /boot
count=$(df --sync -kP /boot | tail -n1 | awk -F ' ' '{print $4}')
count=$(($count-1))
dd if=/dev/zero of=/boot/whitespace bs=1M count=$count || echo "dd exit code $? is suppressed";
rm /boot/whitespace

sync;
# }}}
