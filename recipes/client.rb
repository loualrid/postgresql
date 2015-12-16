#
# Cookbook Name:: postgresql
# Recipe:: client
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

include_recipe "postgresql::ca_certificates"

if platform_family?('debian') && node['postgresql']['version'].to_f > 9.3
  node.default['postgresql']['enable_pgdg_apt'] = true
end

if(node['postgresql']['enable_pgdg_apt']) and platform_family?('debian')
  include_recipe 'postgresql::apt_pgdg_postgresql'
end

if(node['postgresql']['enable_pgdg_yum']) and platform_family?('rhel')
  include_recipe 'postgresql::yum_pgdg_postgresql'
end

file "remove deprecated Pitti PPA apt repository" do
  action :delete
  path "/etc/apt/sources.list.d/pitti-postgresql-ppa"
end

bash "adding postgresql repo" do
  user "root"
  code <<-EOC
  echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > /etc/apt/sources.list.d/pgdg.list
  wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
  EOC
  action :run
end

execute "run apt-get update" do
  command 'apt-get update'
  action :run
end

packages = %w(
  libpq-dev
  git-core 
  curl 
  zlib1g-dev
  libssl-dev 
  libreadline-dev 
  libyaml-dev 
  libsqlite3-dev 
  sqlite3 
  libxml2-dev 
  libxslt1-dev
  postgresql-contrib
)

packages.each { |name| package name }

package "postgresql-#{node['postgresql']['version']}"

#node['postgresql']['client']['packages'].each do |pg_pack|
#  package pg_pack
#end
