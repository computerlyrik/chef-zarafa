#
# Cookbook Name:: zarafa
# Recipe:: zarafa-import
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

dumpfile = "#{node['zarafa']['backup_dir']}/zarafa.dump"

restore_sql = 'mysql '
restore_sql += "-u #{node['zarafa']['mysql_user']} "
restore_sql += "-p#{node['zarafa']['mysql_password']} "
restore_sql += "#{node['zarafa']['mysql_database']} "
restore_sql += "< #{dumpfile}"

execute 'restore_sql' do
  command restore_sql
  only_if ::File.exists(dumpfile)
end

execute "rm #{dumpfile}" do
  action :nothing
  subscribes :run, 'execute[restore_sql]', :immediately
end

package 'bzip2'

filepath = "#{node['zarafa']['backup_dir']}/attachments.tar"

unzip_attachments = 'tar -xvf '
unzip_attachments += "#{filepath} "
unzip_attachments += "-C /var/lib/zarafa/attachments"

execute 'unzip_attachments' do
  command unzip_attachments
  only_if ::File.exists(filepath)
end

execute "rm #{filepath}" do
  action :nothing
  subscribes :run, 'execute[unzip_attachments]', :immediately
end

#directory '/var/lib/zarafa/attachments'
