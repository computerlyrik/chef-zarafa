#
# Cookbook Name:: zarafa
# Recipe:: default
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

if node['zarafa']['backend_type'].nil?
  Chef::Application.fatal!("Set node['zarafa']['backend_type'] !")
end 

if node['zarafa']['ssl']
  include_recipe 'zarafa::ssl'
end 

include_recipe 'zarafa::postfix'
include_recipe 'zarafa::mysql'

include_recipe 'zarafa::zarafa-server'
include_recipe 'zarafa::zarafa-gateway'

include_recipe 'zarafa::apache2'

=begin


#for zarafa webapp
directory "/var/lib/zarafa-webapp/tmp" do
  owner "www-data"
  group "www-data"
  mode 0755
end


directory "/var/log/zarafa/" do
  mode "755"
  owner node['zarafa']['vmail_user']
  group node['zarafa']['vmail_user']
  only_if {node['zarafa']['vmail_user']}
end


=end
