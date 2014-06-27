#
# Cookbook Name:: zarafa
# Recipe:: zarafa-server
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

## INSTALL AND CONFIGURE ZARAFA SERVER #####################################

# Construct Download URL
host = 'http://download.zarafa.com/community/final'
minor = node['zarafa']['version']
major = minor[0, 3]
platform = node['platform']
if platform?('debian')
  platform_version = "#{node['platform_version'][0, 2]}0"
else
  platform_version = node['platform_version']
end
arch = node['kernel']['machine']
license = node['zarafa']['license_type']

url = "#{host}/#{major}/#{minor}/zcp-#{minor}-#{platform}-#{platform_version}-#{arch}-#{license}.tar.gz"
Chef::Log.info("Zarafa Download URL: #{url}")

# Get and unpack the Zarafa packages
ark 'zarafa' do
  url url
  not_if { ::File.exist? '/usr/local/zarafa' }
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
  notifies :reload, 'service[apache2]', :immediately
  notifies :restart, 'service[postfix]', :immediately
end

# Configure
service 'zarafa-server' do
  action [:enable, :start]
end

template '/etc/zarafa/server.cfg' do
  source 'zarafa-server/server.cfg.erb'
  notifies :restart, 'service[zarafa-server]'
end

template '/etc/zarafa/license/base' do
  source 'zarafa-server/base.erb'
  notifies :restart, 'service[zarafa-server]'
end
