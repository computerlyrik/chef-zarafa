#
# Cookbook Name:: zarafa
# Recipe:: mysql
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

# #CONFIGURE MYSQL SERVER #################################
::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

node.set['mysql']['bind_address'] = '127.0.0.1'

node.set['mysql']['server_root_password'] = secure_password if node['mysql']['server_root_password'] == 'ilikerandompasswords'

include_recipe 'mysql::server'
include_recipe 'database::mysql'

mysql_connection_info = { host: 'localhost', username: 'root', password: node['mysql']['server_root_password'] }

::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)
node.set_unless['zarafa']['mysql_password'] = secure_password

mysql_database_user node['zarafa']['mysql_user'] do
  username node['zarafa']['mysql_user']
  password node['zarafa']['mysql_password']
  database_name node['zarafa']['mysql_database']
  connection mysql_connection_info
  action :grant
end

mysql_database node['zarafa']['mysql_database'] do
  connection mysql_connection_info
  action :create
end
