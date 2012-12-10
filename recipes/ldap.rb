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

service "slapd"

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
