###############################################################################
# keystone
###############################################################################

default['bcpc']['keystone']['db'] = 'keystone'

# caching
default['bcpc']['keystone']['enable_caching'] = true

# default log file
default['bcpc']['keystone']['log_file'] = '/var/log/keystone/keystone.log'

# enable debug logging (also caching debug logging).
default['bcpc']['keystone']['debug'] = false

# Set the number of Keystone WSGI processes
default['bcpc']['keystone']['workers'] = nil

# configure SQLAlchemy overflow/QueuePool sizes
default['bcpc']['keystone']['database']['max_overflow'] = 128
default['bcpc']['keystone']['database']['max_pool_size'] = 64
# The driver section below allows either 'sql' or 'ldap' (or 'templated' for catalog)
# Note that not all drivers may support SQL/LDAP, only tinker if you know what you're getting into
default['bcpc']['keystone']['drivers']['assignment'] = 'sql'
default['bcpc']['keystone']['drivers']['catalog'] = 'sql'
default['bcpc']['keystone']['drivers']['credential'] = 'sql'
default['bcpc']['keystone']['drivers']['domain_config'] = 'sql'
default['bcpc']['keystone']['drivers']['endpoint_filter'] = 'sql'
default['bcpc']['keystone']['drivers']['endpoint_policy'] = 'sql'
default['bcpc']['keystone']['drivers']['federation'] = 'sql'
default['bcpc']['keystone']['drivers']['identity'] = 'sql'
default['bcpc']['keystone']['drivers']['identity_mapping'] = 'sql'
default['bcpc']['keystone']['drivers']['oauth1'] = 'sql'
default['bcpc']['keystone']['drivers']['policy'] = 'sql'
default['bcpc']['keystone']['drivers']['revoke'] = 'sql'
default['bcpc']['keystone']['drivers']['role'] = 'sql'
default['bcpc']['keystone']['drivers']['token'] = 'memcache_pool'
default['bcpc']['keystone']['drivers']['trust'] = 'sql'

# Notifications driver
default['bcpc']['keystone']['drivers']['notification'] = 'log'
default['bcpc']['keystone']['notification_format'] = 'cadf'

# Identity configuration
# Understand the implications: https://docs.openstack.org/developer/keystone/configuration.html#domain-specific-drivers
default['bcpc']['keystone']['identity']['domain_configurations_from_database'] = true

default['bcpc']['keystone']['roles']['admin'] = 'admin'
default['bcpc']['keystone']['roles']['member'] = 'member'

default['bcpc']['keystone']['admin']['email'] = "admin@#{node['bcpc']['cloud']['domain']}"
default['bcpc']['keystone']['admin']['username'] = 'admin'
default['bcpc']['keystone']['admin']['project_name'] = 'admin'
default['bcpc']['keystone']['admin']['domain'] = 'default'
default['bcpc']['keystone']['admin']['enable_admin_project'] = true

default['bcpc']['keystone']['service_project']['name'] = 'service'
default['bcpc']['keystone']['service_project']['domain'] = 'default'

default['bcpc']['keystone']['default_domain'] = 'default'

# LDAP credentials used by Keystone
default['bcpc']['ldap']['admin_user'] = nil
default['bcpc']['ldap']['admin_pass'] = nil
default['bcpc']['ldap']['admin_user_domain'] = nil
default['bcpc']['ldap']['admin_project_domain'] = nil
default['bcpc']['ldap']['admin_project_name'] = nil
default['bcpc']['ldap']['config'] = {}

# Domain configs
# <Name> => { description => {}, config => {} }
default['bcpc']['keystone']['domain_config_dir'] = '/etc/keystone/domains'
default['bcpc']['keystone']['domains'] = {}
