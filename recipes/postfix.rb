#
# Cookbook Name:: zarafa
# Recipe:: postfix
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

# #CONFIGURE POSTFIX SERVER############################

destinations = "#{node['fqdn']}, localhost.#{node['domain']}, localhost"
node['zarafa']['additional_domains'].each do |dom|
  destinations << ", #{dom}"
end
node.set['postfix']['main']['mydestination'] = destinations


if node['zarafa']['ssl']
  include_recipe 'zarafa::postfix_ssl'
end

if node['zarafa']['use_rbl']
  node['zarafa']['rbls'].each do |rbl|
    node.set['postfix']['main']['smtpd_recipient_restrictions'] = node['postfix']['main']['smtpd_recipient_restrictions'].append("reject_rbl_client #{rbl}")
  end
end

include_recipe 'postfix::server'

include_recipe 'zarafa::postfix_virtual_users'
include_recipe 'zarafa::postfix_catchall'

include_recipe 'zarafa::postfix_smtpd_sasl'



package "postfix-#{node['zarafa']['backend_type']}"
