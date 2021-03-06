#
# Cookbook Name:: zarafa
# Recipe:: zarafa-ical
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

template '/etc/zarafa/ical.cfg' do
  source 'zarafa-ical/ical.cfg.erb'
  notifies :restart, 'service[zarafa-ical]'
end

service 'zarafa-ical' do
  action [:enable, :start]
end
