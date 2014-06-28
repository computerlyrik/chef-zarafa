#
# Cookbook Name:: zarafa
# Recipe:: postfix_smtpd_sasl
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

node.set['postfix']['main']['smtp_sasl_auth_enable'] = 'yes'
node.set['postfix']['main']['smtpd_sasl_auth_enable'] = 'yes'
node.set['postfix']['main']['smtpd_recipient_restrictions'] = 'permit_mynetworks, permit_sasl_authenticated, reject_unauth_destination'

package 'sasl2-bin'

group "sasl" do
  action :modify
  members "postfix"
  append true
end


service "saslauthd" do
  action [:enable, :start]
end

template "/etc/postfix/sasl/smtpd.conf" do
  source 'postfix/sasl/smtpd.conf.erb'
  notifies :restart, "service[postfix]"
end

template "/etc/default/saslauthd" do
  source 'postfix/sasl/saslauthd.erb'
  notifies :restart, "service[saslauthd]", :immediately
  notifies :restart, "service[postfix]"
end




