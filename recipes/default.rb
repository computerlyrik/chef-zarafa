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

if not node[:zarafa][:backend_type]

# TODO: FAIL 

end 

#TODO: ARCHITECTURE INDEPENDENCY, wget correct zarafa-version, apt-get dependencies of zarafa debian packages
#wget http://download.zarafa.com/community/final/7.0/7.0.8-35178/zcp-7.0.8-35178-ubuntu-12.04-x86_64-free.tar.gz
#unzip

#remote_file "#{Chef::Config[:file_cache_path]}/zcp-7.1.0-36420-ubuntu-12.04-i386-free.tar.gz" do
#  source "http://download.zarafa.com/community/final/7.1/7.1.0-36420/zcp-7.1.0-36420-ubuntu-12.04-i386-free.tar.gz"
#  checksum node['zarafa']['checksum']
#  mode "0644"
#end

## TODO apt-get -f install issue: get deps from .debs and preinstall

#bash "build-and-install-zarafa" do
#  cwd Chef::Config[:file_cache_path]
#  code <<-EOF
#tar -xvf zcp-7.1.0-36420-ubuntu-12.04-i386-free.tar.gz
#(cd zcp-7.1.0-36420-ubuntu-12.04-i386 && dpkg -i lib* && dpkg -i php* && dpkg -i kyoto* && dpkg -i python* && dpkg -i zarafa* && apt-get install -f)
#EOF
#end

##CONFIGURE APACHE SERVER##########################
package "apache2"
package "libapache2-mod-php5"

service "apache2" do
  supports :reload => true
end



##CONFIGURE POSTFIX SERVER############################
package "postfix"

if node[:zarafa][:backend_type] == 'mysql'
package "postfix-mysql"
# check if really needed
#package "postfix-pcre"
#package "postfix-cdb"
end

if node[:zarafa][:backend_type] == 'ldap'
package "postfix-ldap"
end
service "postfix" do
  supports :restart => true
end

execute "postmap catchall" do
  action :nothing
  cwd "/etc/postfix"
  notifies :restart, resources(:service => "postfix")
end

if node[:zarafa][:backend_type] == 'ldap'
ldap_server = search(:node, "recipes:openldap\\:\\:users && domain:#{node['domain']}").first

template "/etc/postfix/ldap-aliases.cf" do
  variables ({:ldap_server => ldap_server})
  notifies :restart, resources(:service => "postfix")
end

template "/etc/postfix/ldap-users.cf" do
  variables ({:ldap_server => ldap_server})
  notifies :restart, resources(:service => "postfix")
end
end

if node[:zarafa][:backend_type] == 'mysql'
execute "postmap -q #{node['zarafa']['catchall']} mysql-aliases.cf" do
  action :nothing
  cwd "/etc/postfix"
  notifies :restart, resources(:service => "postfix")
end

template "/etc/postfix/mysql-aliases.cf" do
  notifies :run, resources(:execute => "postmap -q #{node['zarafa']['catchall']} mysql-aliases.cf")
  notifies :restart, resources(:service => "postfix")
end

#catchall mysql mapping

execute "postmap -q #{node['zarafa']['catchall']} email2email.cf" do
  action :nothing
  cwd "/etc/postfix"
  notifies :restart, resources(:service => "postfix")
end

template "/etc/postfix/mysql-email2email.cf" do
  notifies :run, resources(:execute => "postmap -q #{node['zarafa']['catchall']} email2email.cf")
  notifies :restart, resources(:service => "postfix")
end
end

if not node['zarafa']['catchall'].nil?
  template "/etc/postfix/catchall" do
    notifies :run, resources(:execute => "postmap catchall")
  end
end

template "/etc/postfix/main.cf" do
  notifies :restart, resources(:service => "postfix")
end

## Setup Config for smtp auth
package "sasl2-bin"

service "saslauthd" do
  supports :restart => true
end

template "/etc/postfix/sasl/smtpd.conf" do
  notifies :restart, resources(:service => "postfix")
end

template "/etc/default/saslauthd" do
  notifies :restart, resources(:service => "postfix")
end

if node[:zarafa][:vmail_user]
template "/etc/postfix/master.cf" do
  notifies :restart, resources(:service => "postfix")
end
end

#set permissions for postfix
directory "/var/spool/postfix/var/run/saslauthd" do
  owner "postfix"
end

#TODO CONFIGURE MAILDIR

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


##CONFIGURE ZARAFA#########################################

#install.sh
#TODO

#for zarafa webapp
directory "/var/lib/zarafa-webapp/tmp" do
  owner "www-data"
  group "www-data"
  mode 0755
end

#NOT needed: a2ensite zarafa-webapp => reload
#NOT needed: a2ensite zarafa-webaccess => reload



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

if node[:zarafa][:backend_type] == 'ldap'
template "/etc/zarafa/ldap.cfg" do
  variables ({:ldap_server => ldap_server})
  notifies :restart, resources(:service=>"zarafa-server")
end
end

template "/etc/zarafa/server.cfg" do
  notifies :restart, resources(:service=>"zarafa-server")
end

template "/etc/zarafa/gateway.cfg" do
  notifies :restart, resources(:service=>"zarafa-gateway")
end
if node[:zarafa][:vmail_user]
directory "/var/log/zarafa/" do
  mode "755"
  owner node[:zarafa][:vmail_user]
  group node[:zarafa][:vmail_user]
end
end

# enable ssl
if node[:zarafa][:ssl]
bash "enable https" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOF
   a2enmod ssl
   a2ensite default-ssl
  EOF
  notifies :reload, resources(:service=>"apache2")
end
end

execute "a2enmod rewrite"
  notifies :reload, resources(:service=>"apache2")
end

template "/etc/apache2/sites-available/zarafa-webapp" do
  notifies :reload, resources(:service=>"apache2")
end

template "/etc/apache2/sites-available/zarafa-webaccess" do
  notifies :reload, resources(:service=>"apache2")
end


