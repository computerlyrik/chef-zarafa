#
# Cookbook Name:: zarafa
# Recipe:: postfix_smtpd_sasl
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

package 'sasl2-bin'

group 'sasl' do
  action :modify
  members 'postfix'
  append true
end

directory 'mux_path' do
  path node['zarafa']['sasl_mux_path']
  user 'root'
  group 'sasl'
  mode '710'
end

template '/etc/default/saslauthd' do
  source 'postfix/sasl/saslauthd.erb'
  variables ({mux_path: node['zarafa']['sasl_mux_path']})
  notifies :restart, 'service[saslauthd]', :immediately
  notifies :restart, 'service[postfix]'
end

service 'saslauthd' do
  action [:enable, :start]
end

template '/etc/postfix/sasl/smtpd.conf' do
  source 'postfix/sasl/smtpd.conf.erb'
  notifies :restart, 'service[postfix]'
end


