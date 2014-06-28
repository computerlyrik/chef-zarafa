#
# Cookbook Name:: zarafa
# Recipe:: postfix_catchall
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

catchall_file = '/etc/postfix/catchall'
template catchall_file do
  source 'postfix/catchall.erb'
  notifies :run, 'execute[postmap-catchall]', :immediately
end
execute 'postmap-catchall' do
  command "postmap hash:#{catchall_file}"
  action :nothing
  notifies :restart, 'service[postfix]'
end

if node.set['postfix']['main']['virtual_alias_maps'].nil?
  node.set['postfix']['main']['virtual_alias_maps'] = "hash:#{catchall_file}"
else
  node.set['postfix']['main']['virtual_alias_maps'] << ", hash:#{catchall_file}"
end

