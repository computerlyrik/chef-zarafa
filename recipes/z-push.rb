#
# Cookbook Name:: zarafa
# Recipe:: z-push
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

# #CONFIGURE Z-PUSH############################################

if node['z-push']['timezone'].nil?
  Chef::Application.fatal!("Set node['z-push']['timezone'] !")
end

minor = node['z-push']['version']
major = minor[0, 3]

url = "http://download.z-push.org/final/#{major}/z-push-#{minor}.tar.gz"
Chef::Log.info("Z-Push Download URL: #{url}")

ark 'z-push' do
  url url
  not_if { ::File.exist? '/usr/local/z-push' }
end

directory '/var/lib/z-push' do
  mode 0755
  owner node['apache']['user']
  group node['apache']['user']
end

directory '/var/log/z-push' do
  mode 0755
  owner node['apache']['user']
  group node['apache']['user']
end

apache_conf 'z-push'

template '/usr/local/z-push/config.php' do
  source 'z-push/config.php.erb'
  notifies :restart, 'service[zarafa-server]'
end
