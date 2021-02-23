#!/usr/bin/env bash

# Copyright 2020, Bloomberg Finance L.P.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

# http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -xue
set -o pipefail

apt_key_url=''
apt_url=''
http_proxy=''
https_proxy=''
operations_user=''
operations_user_ssh_pub_key=''
swap_size_gb=''

ARGUMENT_LIST=(
    "apt-key-url"
    "apt-url"
    "http-proxy"
    "https-proxy"
    "operations-user"
    "operations-user-ssh-pub-key"
    "swap-size-gb"
)

# read arguments
opts=$(getopt \
    --longoptions "$(printf "%s:," "${ARGUMENT_LIST[@]}")" \
    --name "$(basename "$0")" \
    --options "" \
    -- "$@"
)

eval set --"$opts"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --apt-key-url)
            export apt_key_url="$2"
            shift 2
            ;;

        --apt-url)
            export apt_url="$2"
            shift 2
            ;;

        --http-proxy)
            export http_proxy=$2
            shift 2
            ;;

        --https-proxy)
            export https_proxy=$2
            shift 2
            ;;

        --operations-user)
            export operations_user="$2"
            shift 2
            ;;

        --operations-user-ssh-pub-key)
            export operations_user_ssh_pub_key="$2"
            shift 2
            ;;

        --swap-size-gb)
            export swap_size_gb=$2
            shift 2
            ;;

        *)
            break
            ;;
    esac
done

function main {
    create_operations_user
    configure_swap
}

function create_operations_user {
    if [ ! "$(getent passwd "${operations_user}")" ]; then
        useradd --create-home --shell '/bin/bash' "${operations_user}"
        mkdir "/home/${operations_user}/.ssh"
        echo "${operations_user_ssh_pub_key}" > \
            "/home/${operations_user}/.ssh/authorized_keys"
        echo "${operations_user} ALL = (ALL) NOPASSWD: ALL" > \
            "/etc/sudoers.d/${operations_user}"
    fi
}

function configure_swap {
    if [ -n "$swap_size_gb" ]; then
        swap_file="/mnt/${swap_size_gb}G.swap"

        if [ ! -e "${swap_file}" ]; then
            fallocate -l "${swap_size_gb}G" "${swap_file}"
            chmod 600 "${swap_file}"
            mkswap "${swap_file}"
        fi

        if ! sudo swapon -s | grep "${swap_file}"; then
            swapon "${swap_file}"
        fi

        if ! grep "${swap_file}" /etc/fstab; then
            echo "${swap_file}  none  swap  sw 0  0" >> /etc/fstab
        fi
    fi
}

main
