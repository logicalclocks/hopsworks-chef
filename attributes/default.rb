#
# Copyright Peter Donald
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

include_attribute "java"
include_attribute "ndb"
include_attribute "glassfish"

default[:glassfish][:user]                = "glassfish"
default[:glassfish][:group]               = "glassfish-admin"
default[:glassfish][:admin][:port]        = 4848
default[:glassfish][:port]                = 8080

default[:hopshub][:admin][:user]          = "admin"
default[:hopshub][:admin][:password]      = "admin"
default[:glassfish][:cert][:password]     = "changeit"
default[:hopshub][:cert][:password]       = "changeit"

default[:hopshub][:twofactor_auth]        = "false"

default[:glassfish][:max_mem]             = 4000
default[:glassfish][:min_mem]             = 2500
default[:glassfish][:max_stack_size]      = 512
default[:glassfish][:max_perm_size]       = 1024

# mysql-server may be part of mysql-cluster (ndb)
default[:mysql][:mysql_bin]               = "#{node[:mysql][:base_dir]}/bin/mysql"
default[:mysql][:mysql_cnf]               = "#{node[:ndb][:base_dir]}/my.cnf"

default[:caramel][:cert][:cn]             = "hops.kth.se"
default[:caramel][:cert][:o]              = "kth"
default[:caramel][:cert][:ou]             = "ict"
default[:caramel][:cert][:l]              = "kista"
default[:caramel][:cert][:s]              = "stockholm"
default[:caramel][:cert][:c]              = "se"
default[:caramel][:cert][:password]       = "hopsan"

default[:caramel][:master][:password]     = "hopsan"

version                                   = "3.1.2.2"
#default[:glassfish][:package_url]             = "http://download.java.net/glassfish/#{version}/release/glassfish-#{version}.zip"
default[:glassfish][:package_url]         = "#{node[:download_url]}/glassfish-#{version}.zip"
default[:glassfish][:base_dir]            = "/usr/local/glassfish-#{version}"
default[:glassfish][:domains_dir]         = "/usr/local/glassfish-#{version}/glassfish/domains"

#default[:glassfish][:mysql_connector]         = "http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.29.tar.gz"
default[:glassfish][:mysql_connector]     = "#{node[:download_url]}/mysql-connector-java-5.1.29.tar.gz"
case node[:hopshub][:twofactor_auth]
 when "true"
   default[:kthfs][:mgr]                  = "#{node[:download_url]}/hop-dashboard-2pc.war"
 else
   default[:kthfs][:mgr]                  = "#{node[:download_url]}/hop-dashboard.war"
end

default[:bind_address]                    = attribute?('cloud') ? cloud['local_ipv4'] : ipaddress

# obligatory provider params
default[:provider][:email]                = ""
default[:provider][:name]                 = ""
default[:provider][:access_key]           = ""
default[:provider][:account_id]           = ""
# openstack-specific param
default[:provider][:keystone_url]         = ""
default[:hopshub][:public_key]            = ""

default[:hopshub][:public_ips]            = ['10.0.2.15']
default[:hopshub][:private_ips]           = ['10.0.2.15']

default[:hopshub][:smtp][:username]       = "hadoop@hops.io"
default[:hopshub][:smtp][:password]       = "admin"
default[:hopshub][:smtp][:server]         = "localhost"
#default[:hopshub][:smtp][:server]         = "smtp.gmail.com"
#default[:hopshub][:smtp][:port]           = "465"
default[:hopshub][:smtp][:port]           = "25"
#default[:hopshub][:smtp][:secure]         = "true"
default[:hopshub][:smtp][:secure]         = "false"

default[:kagent][:enabled]                = "false"
