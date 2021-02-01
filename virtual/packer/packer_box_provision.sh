#!/usr/bin/env bash

set -xue
set -o pipefail

apt_key_url="${BCC_APT_KEY_URL}"
apt_url="${BCC_APT_URL}"
kernel_version="${KERNEL_VERSION}"

function main {
    configure_vagrant_user
    configure_apt
    upgrade_system
    cleanup_apt_cache
    download_debs
    configure_linux_kernel
    cleanup_unused_kernel
}


function configure_vagrant_user {
    group="operators"

    # create the operators group
    groupadd -f ${group}

    # add the vagrant user to the operators group
    usermod -a -G ${group} vagrant
}


function configure_apt {

    if [ -n "$apt_key_url" ]; then
        /usr/bin/wget -qO - "$apt_key_url" | /usr/bin/apt-key add -
    fi

    if [ -n "$apt_url" ]; then
cat << EOF > /etc/apt/sources.list
deb ${apt_url} bionic main restricted universe multiverse
deb ${apt_url} bionic-backports main restricted universe multiverse
deb ${apt_url} bionic-security main restricted universe multiverse
deb ${apt_url} bionic-updates main restricted universe multiverse
EOF
    fi

    apt-get update
}

function upgrade_system {
    env DEBIAN_FRONTEND='noninteractive' DEBIAN_PRIORITY='critical' \
        apt-get -y \
            -o 'Dpkg::Options::=--force-confdef' \
            -o 'Dpkg::Options::=--force-confold' \
        dist-upgrade
}

function cleanup_apt_cache {
    apt-get clean    
}

function download_debs {
    apt-get install --download-only -y -t bionic-backports \
        bird2 init-system-helpers
    apt-get install --download-only -y chrony tinyproxy unbound
}

function configure_linux_kernel {
    if [ -n "$kernel_version" ]; then
	apt-get install -y "linux-${kernel_version}"

	# Disable IPv6
	eval "$(grep ^GRUB_CMDLINE_LINUX= /etc/default/grub)"
	NEW_CMDLINE="${GRUB_CMDLINE_LINUX} ipv6.disable=1"
	sed -i.orig \
            "s/^[#]*GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX=\"${NEW_CMDLINE}\"/" \
            /etc/default/grub
	update-grub
    fi
}

function cleanup_unused_kernel {
    apt-get -y --purge autoremove
}

main
