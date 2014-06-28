#
# Cookbook Name:: zarafa
# Attributes:: default
#
# Copyright 2013, computerlyrik
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

default['zarafa']['version'] = '7.1.10-44973'
default['zarafa']['license_type'] = 'free'

default['zarafa']['mysql_user'] = 'zarafa'
default['zarafa']['mysql_database'] = 'zarafa'
default['zarafa']['mysql_password'] = nil

default['zarafa']['catchall_user'] = nil
default['zarafa']['additional_domains'] = []

default['zarafa']['backend_type'] = 'mysql' # mysql or ldap
default['zarafa']['ssl'] = true
default['zarafa']['vmail_user'] = nil

default['zarafa']['certificate_databag_id'] = nil

override['postfix']['main']['transport_maps'] = ''
override['postfix']['main']['smtp_tls_CAfile'] = ''
override['postfix']['main']['smtpd_tls_CAfile'] = ''
override['postfix']['main']['smtp_sasl_password_maps'] = ''
