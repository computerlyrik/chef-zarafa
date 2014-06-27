#
# Cookbook Name:: zarafa
# Recipe:: apache2
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

##CONFIGURE APACHE #########################################


include_recipe "apache2::default"
include_recipe "apache2::mod_php5"


# enable ssl
if node['zarafa']['ssl']
  include_recipe 'apache2::mod_ssl'
#  execute "a2enmod rewrite"
  apache_site 'default-ssl' do
    action :enable
  end
  apache_site 'default' do
    action :disable
  end
end
