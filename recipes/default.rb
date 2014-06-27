#
# Cookbook Name:: zarafa
# Recipe:: default
#
# Copyright 2012, computerlyrik
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


include_recipe "apache2::default"
include_recipe "apache2::mod_php5"


##CONFIGURE ZARAFA#########################################

# Construct Download URL
host = "http://download.zarafa.com/community/final"
minor = node['zarafa']['version']
major = minor[0,3]
platform = node['platform']
if platform?('debian')
  platform_version = "#{node['platform_version'][0,2]}0"
else
  platform_version = node['platform_version']
end
arch = node['kernel']['machine']
license = node['zarafa']['license_type']

url = "#{host}/#{major}/#{minor}/zcp-#{minor}-#{platform}-#{platform_version}-#{arch}-#{license}.tar.gz"
Chef::Log.info("Zarafa Download URL: #{url}")

# Get and unpack the Zarafa packages
ark "zarafa" do
  url url
  not_if { ::File.exist? "/usr/local/zarafa" }
  notifies :run, 'execute[install_packages_1]', :immediately
  notifies :run, 'execute[install_packages_2]', :immediately
end

execute 'install_packages_1' do
  command 'dpkg -i *.deb'
  ignore_failure true
  cwd '/usr/local/zarafa'
  action :nothing
end

execute 'install_packages_2' do
  command 'apt-get install -fy'
  action :nothing
end


##CONFIGURE APACHE#########################################

# enable ssl
if node['zarafa']['ssl']
  include_recipe 'apache2::mod_ssl'
#  execute "a2enmod rewrite"
  apache_site 'default-ssl' do
    action :enable
  end
  apache_site 'default' do
    action :disable
  end
end


=begin
##CONFIGURE POSTFIX SERVER############################
package "postfix"


package "postfix-mysql" do
  only_if {node['zarafa']['backend_type'] == 'mysql'}
end

package "postfix-ldap" do
  only_if {node['zarafa']['backend_type'] == 'ldap'}
end

#TODO
# check if really needed
#package "postfix-pcre"
#package "postfix-cdb"



service "postfix" do
  supports :restart => true
end

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

  #catchall mysql mapping

  execute "postmap -q #{node['zarafa']['catchall']} email2email.cf" do
    action :nothing
    cwd "/etc/postfix"
    notifies :restart, "service[postfix]")
  end

  template "/etc/postfix/mysql-email2email.cf" do
    notifies :run, "execute => "postmap -q #{node['zarafa']['catchall']} email2email.cf")
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
service "saslauthd" do
  action [:enable, :start]
end

template "/etc/postfix/sasl/smtpd.conf" do
  notifies :restart, "service[postfix]"
end

template "/etc/default/saslauthd" do
  notifies :restart, "service[saslauthd]", :immediately
  notifies :restart, "service[postfix]"
end

template "/etc/postfix/master.cf" do
  notifies :restart, "service[postfix]"
  only_if { node['zarafa']['vmail_user'] }
end

#set permissions for postfix
directory "/var/spool/postfix/var/run/saslauthd" do
  owner "postfix"
end


##CONFIGURE MYSQL SERVER#################################

node.set['mysql']['bind_address'] = "127.0.0.1"

include_recipe "mysql::server"
include_recipe "database::mysql"

mysql_connection_info = {:host => "localhost", :username => 'root', :password => node['mysql']['server_root_password']}

::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)
node.set_unless['zarafa']['mysql_password'] = secure_password

mysql_database_user node['zarafa']['mysql_user'] do
  username  node['zarafa']['mysql_user']
  password  node['zarafa']['mysql_password']
  database_name node['zarafa']['mysql_database']
  connection mysql_connection_info
  action :grant
end

mysql_database node['zarafa']['mysql_database'] do
  connection mysql_connection_info
  action :create
end 




execute "/usr/local/zarafa/install.sh" do
  cwd "/usr/local/zarafa"
  ignore_failure true
  action :nothing
  subscribes :run, "ark[zarafa]", :immediately
end

execute "apt-get install -f -y" do
  action :nothing
  subscribes :run, "ark[zarafa]", :immediately
end
#TODO: FAIL and run install.sh

#for zarafa webapp
directory "/var/lib/zarafa-webapp/tmp" do
  owner "www-data"
  group "www-data"
  mode 0755
end



#not necessary - got by program itself package "php-gettext"
#internally: zarafa-admin -s

#zarafa-admin -c user

service "zarafa-server" do 
  supports :restart => true, :start => true
  action :start
end

service "zarafa-gateway" do 
  supports :restart => true, :start => true
  action :start
end
 
template "/etc/zarafa/ldap.cfg" do
  variables ({:ldap_server => ldap_server})
  notifies :restart, "service[zarafa-server]"
  only_if { node['zarafa']['backend_type'] == 'ldap' }
end

template "/etc/zarafa/server.cfg" do
  notifies :restart, "service[zarafa-server]"
end

template "/etc/zarafa/gateway.cfg" do
  notifies :restart, "service[zarafa-gateway]"
end

directory "/var/log/zarafa/" do
  mode "755"
  owner node['zarafa']['vmail_user']
  group node['zarafa']['vmail_user']
  only_if {node['zarafa']['vmail_user']}
end


=end
