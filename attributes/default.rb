include_attribute "ndb"
include_attribute "hadoop_spark"
include_attribute "flink"
include_attribute "elastic"
include_attribute "zeppelin"
include_attribute "glassfish"


node.default.glassfish.variant             = "payara"
node.default.glassfish.user                = "glassfish"
node.default.glassfish.group               = "glassfish-admin"
node.default.hopsworks.admin.port          = 4848
node.default.hopsworks.port                = "8080"
node.default.glassfish.admin.port          = node.hopsworks.admin.port
node.default.glassfish.port                = node.hopsworks.port.to_i
node.default.glassfish.version             = '4.1.152'
#node.default.glassfish.base_dir            = "/home/glassfish"
node.default.glassfish.install_dir         = "/usr/local"
node.default.glassfish.domains_dir         = "/srv/glassfish"
default.hopsworks.max_mem                  = "4000"
node.default.glassfish.max_mem             = node.hopsworks.max_mem.to_i
default.hopsworks.min_mem                  = "1024"
node.default.glassfish.min_mem             = node.hopsworks.min_mem.to_i
default.hopsworks.max_stack_size           = "512"
node.default.glassfish.max_stack_size      = node.hopsworks.max_stack_size.to_i
default.hopsworks.max_perm_size            = "1024"
node.default.glassfish.max_perm_size       = node.hopsworks.max_perm_size.to_i
node.default.glassfish.package_url         = node.download_url + "/payara-#{node.glassfish.version}.zip"
default.hopsworks.cauth_url                = "#{node.download_url}/otp-auth-1.0.jar"
default.hopsworks.war_url                  = "#{node.download_url}/hopsworks.war"

default.hopsworks.admin.user               = "adminuser"
default.hopsworks.admin.password           = "adminpw"
node.default.glassfish.cert.password       = "#{node.hopsworks.admin.password}"
#default.hopsworks.default_user             = "admin@kth.se"
#default.hopsworks.default_password         = "admin"
default.hopsworks.twofactor_auth           = "false"

# # mysql-server may be part of mysql-cluster (ndb)
# default.mysql.mysql_bin                  = "#{node.mysql.base_dir}/bin/mysql"
# default.mysql.mysql_cnf                  = "#{node.ndb.base_dir}/my.cnf"

default.hopsworks.mysql_connector_url      = "http://snurran.sics.se/hops/mysql-connector-java-5.1.29-bin.jar"

default.hopsworks.cert.cn                  = "sics.se"
default.hopsworks.cert.o                   = "swedish ict"
default.hopsworks.cert.ou                  = "sics"
default.hopsworks.cert.l                   = "kista"
default.hopsworks.cert.s                   = "stockholm"
default.hopsworks.cert.c                   = "se"

default.hopsworks.cert.password            = "changeit"
default.hopsworks.master.password          = "adminpw"

# default.bind_address                    = attribute?('cloud') ? cloud['local_ipv4' : ipaddress

default.hopsworks.public_ips               = ['10.0.2.15']
default.hopsworks.private_ips              = ['10.0.2.15']

default.kagent.enabled                     = "false"

default.hopsworks.smtp                     = "smtp.gmail.com"
default.hopsworks.gmail.email              = "hopsworks@gmail.com"
default.hopsworks.gmail.password           = "password"
default.hopsworks.gmail.placeholder        = "http://snurran.sics.se/hops/hopsworks.email"

# #quotas
default.hopsworks.yarn_default_quota_mins  = "1000"
default.hopsworks.hdfs_default_quota_gbs   = "200"
default.hopsworks.max_num_proj_per_user    = "5"

node.default.apache_hadoop.user_envs       = "false"
