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

node.set['postfix']['main']['smtp_sasl_auth_enable'] = 'yes'
node.set['postfix']['main']['smtpd_recipient_restrictions'] = 'permit_mynetworks, permit_sasl_authenticated, reject_unauth_destination'

destinations = "#{node['fqdn']}, localhost.#{node['domain']}, localhost"
node['zarafa']['additional_domains'].each do |dom|
  destinations << ", #{dom}"
end

node.set['postfix']['main']['mydestination'] = destinations
node.set['postfix']['main']['message_size_limit'] = 31_457_280 # 30M

case node[:zarafa][:backend_type]

when 'mysql'
  virtual_alias_maps = 'hash:/etc/postfix/catchall'
  virtual_mailbox_maps = ''

when 'ldap'
  if Chef::Config['solo']
    Chef::Log.warn('This recipe uses search. Chef Solo does not support search. Ldap search will not be executed')
    ldap_server = node
  else
    ldap_server = search(:node, "recipes:openldap\\:\\:users && domain:#{node['domain']}").first
  end

  template '/etc/postfix/ldap-aliases.cf' do
    variables ({ ldap_server: ldap_server })
    notifies :restart, 'service[postfix]', :delayed
  end

  template '/etc/postfix/ldap-users.cf' do
    variables ({ ldap_server: ldap_server })
    notifies :restart, 'service[postfix]', :delayed
  end

  virtual_alias_maps = 'ldap:/etc/postfix/ldap-aliases.cf'
  unless node['zarafa']['catchall'].nil?
    virtual_alias_maps << ', hash:/etc/postfix/catchall'
  end
  virtual_mailbox_maps = 'ldap:/etc/postfix/ldap-users.cf'
end

node.set['postfix']['main']['virtual_mailbox_domains'] = node['domain']
node.set['postfix']['main']['virtual_transport'] = 'lmtp:127.0.0.1:2003'

node.set['postfix']['main']['virtual_mailbox_maps'] = virtual_mailbox_maps
node.set['postfix']['main']['virtual_alias_maps'] = virtual_alias_maps

include_recipe 'postfix::server'

package "postfix-#{node['zarafa']['backend_type']}"

if node['zarafa']['backend_type'] == 'ldap'

end

if node[:zarafa][:backend_type] == 'mysql'

end
