#
# Cookbook Name:: zarafa
# Recipe:: postfix_virtual_users
#
# Copyright 2012, 2014, computerlyrik
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

case node['zarafa']['backend_type']
when 'mysql'
  template '/etc/postfix/mysql-users.cf' do
    source 'postfix/mysql-users.cf.erb'
    notifies :restart, 'service[postfix]'
  end
when 'ldap'
  if Chef::Config['solo']
    Chef::Log.warn('This recipe uses search. Chef Solo does not support search. Ldap search will not be executed')
    ldap_server = node
  else
    ldap_server = search(:node, "recipes:openldap\\:\\:users && domain:#{node['domain']}").first
  end

  template '/etc/postfix/ldap-users.cf' do
    source 'postfix/ldap-users.cf.erb'
    variables ({ ldap_server: ldap_server })
    notifies :restart, 'service[postfix]', :delayed
  end
  template '/etc/postfix/ldap-aliases.cf' do
    source 'postfix/ldap-aliases.cf.erb'
    variables ({ ldap_server: ldap_server })
    notifies :restart, 'service[postfix]', :delayed
  end

end
