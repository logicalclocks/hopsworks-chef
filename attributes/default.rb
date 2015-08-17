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
default[:glassfish][:version]             = '4.1'
default[:hopsworks][:admin][:user]        = "admin"
default[:hopsworks][:admin][:password]    = "changeit"
default[:glassfish][:cert][:password]     = node[:hopsworks][:admin][:password]

default[:hopsworks][:twofactor_auth]        = "false"

default[:glassfish][:max_mem]             = 4000
default[:glassfish][:min_mem]             = 2500
default[:glassfish][:max_stack_size]      = 512
default[:glassfish][:max_perm_size]       = 1024

# mysql-server may be part of mysql-cluster (ndb)
default[:mysql][:mysql_bin]               = "#{node[:mysql][:base_dir]}/bin/mysql"
default[:mysql][:mysql_cnf]               = "#{node[:ndb][:base_dir]}/my.cnf"

default[:karamel][:cert][:cn]             = "hops.kth.se"
default[:karamel][:cert][:o]              = "kth"
default[:karamel][:cert][:ou]             = "ict"
default[:karamel][:cert][:l]              = "kista"
default[:karamel][:cert][:s]              = "stockholm"
default[:karamel][:cert][:c]              = "se"

default[:hopsworks][:cert][:password]     = "changeit"

default[:karamel][:master][:password]     = "changeit"

version                                   = node[:glassfish][:version]
default[:glassfish][:package_url]             = "http://download.java.net/glassfish/#{version}/release/glassfish-#{version}.zip"
#default[:glassfish][:package_url]         = "#{node[:download_url]}/glassfish-#{version}.zip"
default[:grizzly][:jar_url]               = "#{node[:download_url]}/nucleus-grizzly-all.jar"

default[:glassfish][:cauth_url]           = "#{node[:download_url]}/otp-auth-1.0.jar"

node.normal[:glassfish][:base_dir]        = "/usr/local/glassfish-#{version}"
node.normal[:glassfish][:install_dir]     = "/usr/local/glassfish-#{version}"
node.normal[:glassfish][:domains_dir]     = "/usr/local/glassfish-#{version}/glassfish/domains"

#default[:glassfish][:mysql_connector]         = "http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.29.tar.gz"
node.normal[:glassfish][:mysql_connector] = "#{node[:download_url]}/mysql-connector-java-5.1.29.tar.gz"
case node[:hopsworks][:twofactor_auth]
 when "true"
   default[:hopsworks][:mgr]                  = "#{node[:download_url]}/hop-dashboard-2pc.war"
 else
   default[:hopsworks][:mgr]                  = "#{node[:download_url]}/hopsworks.war"
end

default[:bind_address]                    = attribute?('cloud') ? cloud['local_ipv4'] : ipaddress


default[:zeppelin][:version]              = "0.5.0-incubating"
default[:zeppelin][:spark_version]        = "1.3.1"
default[:zeppelin][:hadoop_version]       = "2.3"
#default[:zeppelin][:url]                  = "http://apache.mirrors.spacedump.net/incubator/zeppelin/#{node[:zeppelin][:version]}/zeppelin-#{node[:zeppelin][:version]}-bin-spark-#{node[:zeppelin][:spark_version]}_hadoop-#{node[:zeppelin][:hadoop_version]}.tgz"
default[:zeppelin][:url]                  = "http://snurran.sics.se/hops/zeppelin-#{node[:zeppelin][:version]}-bin-spark-#{node[:zeppelin][:spark_version]}_hadoop-#{node[:zeppelin][:hadoop_version]}.tgz"
default[:zeppelin][:user]                 = "#{node[:glassfish][:user]}"
default[:zeppelin][:dir]                  = node[:hadoop][:dir]
default[:zeppelin][:home]                 = "#{node[:zeppelin][:dir]}/zeppelin"

# obligatory provider params
default[:provider][:email]                = ""
default[:provider][:name]                 = ""
default[:provider][:access_key]           = ""
default[:provider][:account_id]           = ""
# openstack-specific param
default[:provider][:keystone_url]         = ""
default[:hopsworks][:public_key]          = ""

default[:hopsworks][:public_ips]          = ['10.0.2.15']
default[:hopsworks][:private_ips]         = ['10.0.2.15']

default[:hopsworks][:smtp][:username]     = "hadoop@hops.io"
default[:hopsworks][:smtp][:password]     = "admin"
default[:hopsworks][:smtp][:server]       = "localhost"
#default[:hopsworks][:smtp][:server]       = "smtp.gmail.com"
#default[:hopsworks][:smtp][:port]         = "465"
default[:hopsworks][:smtp][:port]         = "25"
#default[:hopsworks][:smtp][:secure]       = "true"
default[:hopsworks][:smtp][:secure]       = "false"

default[:kagent][:enabled]                = "false"



default[:hopsworks][:smtp]                = "smtp.gmail.com"
default[:hopsworks][:email_address]       = "yourusername@gmail.com"
default[:hopsworks][:smtp_password]       = "enterpasswordhere"

node.normal[:hadoop][:user_envs]          = "false"

