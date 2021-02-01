#!/bin/bash

# Copyright 2021, Bloomberg Finance L.P.
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

set -xe


root_dir=$(git rev-parse --show-toplevel)
packer_dir=$(dirname $(dirname "$0"))
virtual_dir="${root_dir}/virtual"


config_variables="${packer_dir}/variables.json"
BASE_BOX=($(jq -r '.base_box' $config_variables))
BASE_BOX_VERSION=($(jq -r '.base_box_version' $config_variables))
OUTPUT_PACKER_BOX_NAME=($(jq -r '.output_packer_box_name' $config_variables))
base_box_exists=$(vagrant box list --machine-readable | grep -i "$BASE_BOX.*$BASE_BOX_VERSION")
if [ -z "$base_box_exists" ]; then
    vagrant box add --insecure "$BASE_BOX" --box-version "$BASE_BOX_VERSION" --provider virtualbox; 

fi

# create the base box
# Use the script path to find the packer directory
cd "${packer_dir}"
if [ -d "output-vagrant" ]; then
    rm -drf output-vagrant
fi
current_packer_ver=$(packer --version)
required_packer_ver="1.4.0"
if [ "$(printf '%s\n' "$required_packer_ver" "$current_packer_ver" | sort -V | head -n1)" = "$required_packer_ver" ]; then
    packer build --force --var-file=variables.json "config.json"
    cd "output-vagrant"
    vagrant box add --force --clean --name "$OUTPUT_PACKER_BOX_NAME" file://package.box
else
    printf "Packer version is too low. Please install at least %s\n." "$required_packer_ver"
fi


# Add libvirt version of packer-box
if [ "${VAGRANT_DEFAULT_PROVIDER}" == "libvirt" ] ; then
    vagrant mutate "$OUTPUT_PACKER_BOX_NAME" libvirt
fi



