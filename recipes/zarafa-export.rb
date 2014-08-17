#
# Cookbook Name:: zarafa
# Recipe:: zarafa-export
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

directory node['zarafa']['backup_dir']

dumpfile = "#{node['zarafa']['backup_dir']}/zarafa.dump"

dump_sql = 'mysqldump '
dump_sql += "-h localhost "
dump_sql += "-u #{node['zarafa']['mysql_user']} "
dump_sql += "-p#{node['zarafa']['mysql_password']} "
dump_sql += "#{node['zarafa']['mysql_database']} "
dump_sql += "--skip-lock-tables --single-transaction --skip-opt --add-drop-table --create-options --extended-insert --quick --set-charset "
dump_sql += "> #{node['zarafa']['backup_dir']}/zarafa.dump"

execute 'dump_sql' do
  command dump_sql
  not_if { ::File.exists?(dumpfile) }
end

package 'bzip2'

filepath = "#{node['zarafa']['backup_dir']}/attachments.tar"

zip_attachments = 'tar -cf '
zip_attachments += "#{filepath} "
zip_attachments += "/var/lib/zarafa/attachments"

execute 'zip_attachments' do
  command zip_attachments
  not_if { ::File.exists?(filepath) }
end

