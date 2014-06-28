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

node.set['postfix']['main']['mydomain'] = node['domain']
node.set['postfix']['main']['myorigin'] = '/etc/mailname'

node.set['postfix']['main']['virtual_mailbox_domains'] = node['domain']
node.set['postfix']['main']['virtual_transport'] = 'lmtp:127.0.0.1:2003'

destinations = "#{node['fqdn']}, localhost.#{node['domain']}, localhost"
node['zarafa']['additional_domains'].each do |dom|
  destinations << ", #{dom}"
end

node.set['postfix']['main']['mydestination'] = destinations
node.set['postfix']['main']['message_size_limit'] = 31_457_280 # 30M

include_recipe 'zarafa::postfix_smtpd_sasl'
include_recipe 'zarafa::postfix_virtual_users'
include_recipe 'zarafa::postfix_catchall'
include_recipe 'postfix::server'

package "postfix-#{node['zarafa']['backend_type']}"
