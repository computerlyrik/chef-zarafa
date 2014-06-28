#
# Cookbook Name:: zarafa
# Recipe:: zarafa-gateway
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

certificate_path = '/etc/zarafa/ssl'

certificate_manage 'zarafa-gateway' do
  search_id node['zarafa']['certificate_databag_id']
  cert_path certificate_path
  not_if { node['zarafa']['certificate_databag_id'].nil? }
end

template '/etc/zarafa/gateway.cfg' do
  source 'zarafa-gateway/gateway.cfg.erb'
  variables(
      ssl_certificate: "#{certificate_path}/certs/#{node['fqdn']}.pem",
      ssl_key: "#{certificate_path}/private/#{node['fqdn']}.key"
  )
  notifies :restart, 'service[zarafa-gateway]'
end

service 'zarafa-gateway' do
  action [:enable, :start]
end
