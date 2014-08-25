#
# Cookbook Name:: zarafa
# Attributes:: default
#
# Copyright 2013, 2014 computerlyrik
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


default['postfix']['main']['mydomain'] = node['domain']
default['postfix']['main']['myorigin'] = '/etc/mailname'

default['postfix']['main']['virtual_mailbox_domains'] = node['domain']
default['postfix']['main']['virtual_transport'] = 'lmtp:127.0.0.1:2003'

default['postfix']['main']['message_size_limit'] = 31457280 # 30M
default['postfix']['main']['mailbox_size_limit'] = 0

default['zarafa']['use_rbl'] = false
default['zarafa']['rbls'] = ['zen.spamhaus.org', 'bl.spamcop.net', 'cbl.abuseat.org']

override['postfix']['main']['access_maps'] = ''
override['postfix']['main']['transport_maps'] = ''
override['postfix']['main']['smtp_tls_CAfile'] = ''
override['postfix']['main']['smtpd_tls_CAfile'] = ''
override['postfix']['main']['smtp_sasl_password_maps'] = ''


# for postfix_virtual_users
case node['zarafa']['backend_type']
when 'mysql'
  default['postfix']['main']['virtual_mailbox_maps'] = 'mysql:/etc/postfix/mysql-users.cf'
  default['postfix']['main']['virtual_alias_maps'] = nil
when 'ldap'
  default['postfix']['main']['virtual_mailbox_maps'] = 'ldap:/etc/postfix/ldap-users.cf'
  default['postfix']['main']['virtual_alias_maps'] = 'ldap:/etc/postfix/ldap-aliases.cf'
end

# postfix_smtp_sasl
default['postfix']['main']['smtpd_sasl_auth_enable'] = 'yes'
default['postfix']['main']['smtpd_recipient_restrictions'] = ['permit_mynetworks', 'permit_sasl_authenticated', 'reject_unauth_destination']

default['zarafa']['sasl_mux_path'] = '/var/run/saslauthd' #'/var/spool/postfix/var/run/saslauthd'
