# -*- mode: ruby -*-
# vi: set ft=ruby :

# Copyright:: 2020 Bloomberg Finance L.P.
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
module Util
  # returns 'virtual_' (the vagrant-libvirt default) or a prefix based on
  # whether or not the environment var 'BCC_ENABLE_LIBVIRT_PREFIX is set
  def self.libvirt_prefix
    # return 'virtual' if prefix not enabled
    unless ENV.key?('BCC_ENABLE_LIBVIRT_PREFIX')
      return 'virtual_'
    end

    require 'digest/sha1'
    Digest::SHA1.hexdigest(__dir__)[0, 7] + '_'
  end

  # returns vbox_name with or without suffix base on set vs unset
  # of the environment var 'BCC_ENABLE_VBOX_SUFFIX'
  def self.vbox_name(name)
    # return name if suffix not enabled
    unless ENV.key?('BCC_ENABLE_VBOX_SUFFIX')
      return name
    end
    # return name + hashed __dir__
    require 'digest/sha1'
    hash = Digest::SHA1.hexdigest(__dir__)[0, 7]
    name + '_' + hash
  end

  def self.mount_apt_cache(config)
    if ENV.key?('BCC_DISABLE_APT_CACHE')
      return
    end
    user_data_path = Vagrant.user_data_path.to_s
    cache_dir = File.join(user_data_path, 'cache', 'apt', config.vm.box)
    apt_cache_dir = '/var/cache/apt/archives'
    config.vm.synced_folder cache_dir, apt_cache_dir,
        create: true, owner: '_apt'
  end
end
