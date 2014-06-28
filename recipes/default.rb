#
# Cookbook Name:: zarafa
# Recipe:: default
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

if node['zarafa']['backend_type'].nil?
  Chef::Application.fatal!("Set node['zarafa']['backend_type'] !")
end 

include_recipe 'zarafa::apache2'
include_recipe 'zarafa::postfix'
include_recipe 'zarafa::mysql'

include_recipe 'zarafa::zarafa-gateway'

include_recipe 'zarafa::zarafa-server'

=begin

if node['zarafa']['backend_type'] == 'ldap'
  if Chef::Config['solo']
    Chef::Log.warn("This recipe uses search. Chef Solo does not support search. Ldap search will not be executed")
    ldap_server = node
  else
    ldap_server = search(:node, "recipes:openldap\\:\\:users && domain:#{node['domain']}").first
  end

  template "/etc/postfix/ldap-aliases.cf" do
    variables ({:ldap_server => ldap_server})
    notifies :restart, "service[postfix]"
  end

  template "/etc/postfix/ldap-users.cf" do
    variables ({:ldap_server => ldap_server})
    notifies :restart, "service[postfix]"
  end
end
=begin
if node[:zarafa][:backend_type] == 'mysql'
  execute "postmap -q #{node['zarafa']['catchall']} mysql-aliases.cf" do
    action :nothing
    cwd "/etc/postfix"
    notifies :restart, "service[postfix]")
  end

  template "/etc/postfix/mysql-aliases.cf" do
    notifies :run, "execute => "postmap -q #{node['zarafa']['catchall']} mysql-aliases.cf")
    notifies :restart, "service[postfix]")
  end


end

execute "postmap catchall" do
  action :nothing
  cwd "/etc/postfix"
  notifies :restart, "service[postfix]"
end

template "/etc/postfix/catchall" do
  notifies :run, "execute[postmap catchall]"
  not_if { node['zarafa']['catchall'].nil? }
end

template "/etc/postfix/main.cf" do
  notifies :restart, "service[postfix]"
end

## Setup Config for smtp auth
package "sasl2-bin"

#TODO debug why is not


template "/etc/postfix/master.cf" do
  notifies :restart, "service[postfix]"
  only_if { node['zarafa']['vmail_user'] }
end

#set permissions for postfix








#for zarafa webapp
directory "/var/lib/zarafa-webapp/tmp" do
  owner "www-data"
  group "www-data"
  mode 0755
end


 





directory "/var/log/zarafa/" do
  mode "755"
  owner node['zarafa']['vmail_user']
  group node['zarafa']['vmail_user']
  only_if {node['zarafa']['vmail_user']}
end


=end
