#
# Cookbook Name:: zarafa
# Recipe:: ldap
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

include_recipe "openldap::server"

::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

# Set up a anon user for auth purpose
node.set_unless['openldap']['anon_user'] = "anon"
node.set_unless['openldap']['anon_binddn'] = "cn=#{node['openldap']['anon_user']},#{node['openldap']['basedn']}"
unless node['openldap']['anon_pass']
  node.set['openldap']['anon_pass'] = secure_password
  anon_pass = Mixlib::ShellOut.new("slappasswd -h {ssha} -s #{node['openldap']['anon_pass']}").run_command
  Chef::Log.info(anon_pass.stdout)
  node.set['openldap']['anon_hash'] = anon_pass.stdout.chomp
end


openldap_node node['openldap']['anon_binddn'] do
  attributes ({
    :objectClass => ["account","simpleSecurityObject","top"],
    :uid => node['openldap']['anon_user'],
    :userPassword => node['openldap']['anon_hash']
  })
end
  
openldap_config "olcDatabase={1}hdb,cn=config" do
  attributes ({
    :olcDbDirectory => node['openldap']['db_dir'],
    :olcSuffix => node['openldap']['basedn'],
    :olcAccess => [ 
      "{0}to attrs=userPassword,shadowLastChange 
          by self write 
          by anonymous auth 
          by dn=\"#{node['openldap']['rootdn']}\" write 
          by dn=\"#{node['openldap']['anon_binddn']}\" read 
          by * none",
      "{1}to dn.base="" 
          by * read",
      "{2}to * 
          by self write 
          by dn=\"#{node['openldap']['rootdn']}\" write 
          by dn=\"#{node['openldap']['anon_binddn']}\" read"
    ],
    :olcLastMod => "TRUE",
    :olcRootDN => node['openldap']['rootdn'],
    :olcRootPW => node['openldap']['roothash']
  })
end


#service "slapd"

=begin
openldap_config "cn=config" do
  attributes ({
    :olcArgsFile => "#{node['openldap']['run_dir']}/slapd.args",
    :olcPidFile => "#{node['openldap']['run_dir']}/slapd.pid",
    :olcLogLevel => node['openldap']['loglevel']
  })
end
=end

#by default activated schemas
#cn={0}core.ldif
#cn={1}cosine.ldif
#cn={2}nis.ldif
#cn={3}inetorgperson.ldif




template "/etc/ldap/schema/zarafa.schema"
template "/etc/ldap/zarafa.conf"

#execute "slaptest -f /etc/ldap/zarafa.conf -F #{node['openldap']['dir']}/slapd.d" do
#  action :nothing
#  subscribes :run, resources(:template => "/etc/ldap/zarafa.conf")
#  subscribes :run, resources(:template => "/etc/ldap/schema/zarafa.schema")
#  notifies :restart, resources(:service => "slapd")
#end

#see http://www.zarafa.com/wiki/index.php/OpenLdap:_Switch_to_dynamic_config_backend_%28cn%3Dconfig%29 how to convert from schema to this template file
openldap_config "cn=zarafa,cn=schema,cn=config" do
  template "schema=zarafa.ldif.erb" 
  action :create
end
