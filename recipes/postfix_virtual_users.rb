#
# Cookbook Name:: zarafa
# Recipe:: postfix_virtual_users
#
# Copyright 2014, computerlyrik
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

catchall_file = '/etc/postfix/catchall'
template catchall_file do
  source 'postfix/catchall.erb'
  notifies :run, 'execute[postmap-catchall]', :immediately
end
execute 'postmap-catchall' do
  command "postmap hash:#{catchall_file}"
  action :nothing
  notifies :restart, 'service[postfix]'
end

case node[:zarafa][:backend_type]
when 'mysql'
  template '/etc/postfix/mysql-aliases.cf' do
    source 'postfix/mysql-aliases.cf.erb'
    notifies :restart, 'service[postfix]'
  end
  virtual_alias_maps = "hash:#{catchall_file}"
  virtual_mailbox_maps = 'mysql:/etc/postfix/mysql-aliases.cf'
when 'ldap'
  if Chef::Config['solo']
    Chef::Log.warn('This recipe uses search. Chef Solo does not support search. Ldap search will not be executed')
    ldap_server = node
  else
    ldap_server = search(:node, "recipes:openldap\\:\\:users && domain:#{node['domain']}").first
  end

  template '/etc/postfix/ldap-aliases.cf' do
    variables ({ ldap_server: ldap_server })
    notifies :restart, 'service[postfix]', :delayed
  end

  template '/etc/postfix/ldap-users.cf' do
    variables ({ ldap_server: ldap_server })
    notifies :restart, 'service[postfix]', :delayed
  end

  virtual_alias_maps = 'ldap:/etc/postfix/ldap-aliases.cf'
  unless node['zarafa']['catchall'].nil?
    virtual_alias_maps << ', hash:/etc/postfix/catchall'
  end
  virtual_mailbox_maps = 'ldap:/etc/postfix/ldap-users.cf'
end

node.set['postfix']['main']['virtual_mailbox_maps'] = virtual_mailbox_maps
node.set['postfix']['main']['virtual_alias_maps'] = virtual_alias_maps
