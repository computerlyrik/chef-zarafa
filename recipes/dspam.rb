#
# Cookbook Name:: zarafa
# Recipe:: dspam
#
# Copyright 2012, 2014 computerlyrik
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
include_recipe 'dspam'

node.set['clamav']['clamd']['tcp_socket'] = 3310
node.set['clamav']['clamd']['tcp_addr'] = '127.0.0.1'
node.set['clamav']['clamd']['enabled'] = true
include_recipe 'clamav'

# template "/etc/dspam/dspam.conf"

template '/etc/postfix/dspam_filter_access' do
  notifies :restart, 'service[postfix]'
end

template '/etc/postfix/master.cf' do
  notifies :restart, 'service[postfix]'
end

# #configure chrooted postfix
directory '/var/spool/postfix/var/run/dspam' do
  owner 'dspam'
end

template '/etc/dspam/dspam.conf' do
  notifies :restart, 'service[dspam]'
  notifies :restart, 'service[postfix]'
end
