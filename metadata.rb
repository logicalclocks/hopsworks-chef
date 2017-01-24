name             "hopsworks"
maintainer       "Jim Dowling"
maintainer_email "jdowling@kth.se"
license          "Apache v2.0"
description      "Installs/Configures HopsWorks, the UI for Hops Hadoop."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.0"
source_url       "https://github.com/hopshadoop/hopsworks-chef"


%w{ ubuntu debian centos rhel }.each do |os|
  supports os
end

depends 'glassfish'
depends 'ndb'
depends 'kagent'
depends 'hops'
depends 'elastic'
depends 'hadoop_spark'
depends 'flink'
depends 'zeppelin'
depends 'compat_resource'
depends 'ulimit2'
depends 'authbind'
depends 'apache_hadoop'
depends 'epipe'
depends 'livy'
depends 'kkafka'
depends 'kzookeeper'
depends 'drelephant'
depends 'dela'
depends 'java'
depends 'tensorflow'
depends 'hopslog'
depends 'hopsmonitor'


#link:Click <a target='_blank' href='https://%host%:4848'>here</a> to launch Glassfish in your browser (http)
recipe  "hopsworks::install", "Installs Glassfish"

#link:Click <a target='_blank' href='http://%host%:8080/hopsworks'>here</a> to launch hopsworks in your browser (http)
recipe  "hopsworks", "Installs HopsWorks war file, starts glassfish+application."

recipe  "hopsworks::dev", "Installs development libraries needed for HopsWorks development."

recipe  "hopsworks::letsencypt", "Given a glassfish installation and a letscrypt installation, update glassfish's key."

recipe  "hopsworks::purge", "Deletes glassfish installation."

#######################################################################################
# Required Attributes
#######################################################################################


attribute "hopsworks/twofactor_auth",
          :description => "twofactor_auth (default: false)",
          :type => 'string',
          :required => "required"

attribute "hopsworks/email",
          :description => "Email address. Recommended to use a gmail account",
          :required => "required",
          :type => 'string'

attribute "hopsworks/email_password",
          :description => "Password for email account. ",
          :required => "required",
          :type => 'string'


attribute "hopsworks/smtp",
          :description => "Ip Address/hostname of SMTP server (default is smtp.gmail.com)",
          :type => 'string'

attribute "hopsworks/smtp_port",
          :description => "Port of SMTP server (default is 587)",
          :type => 'string'

attribute "hopsworks/smtp_ssl_port",
          :description => "SSL port of SMTP server (default is 465)",
          :type => 'string'

attribute "hopsworks/admin/user",
          :description => "Username for the Administration account on the Web Application Server",
          :type => 'string',
          :required => "required"

attribute "hopsworks/admin/password",
          :description => "Password for the Administration account on the Web Application Server",
          :type => 'string',
          :required => "required"

attribute "mysql/user",
          :description => "Username for the MySQL Server Accounts",
          :type => 'string',
          :required => "required"

attribute "mysql/password",
          :description => "Password for the MySQL Server Accounts",
          :type => 'string',
          :required => "required"


#######################################################################################
# Non-Required Attributes
#######################################################################################

attribute "hopsworks/dir",
          :description => "Installation directory for the glassfish binaries",
          :type => 'string'

attribute "hopsworks/user",
          :description => "Hopsworks/glassfish username to run service as",
          :type => 'string'

attribute "hopsworks/group",
          :description => "Hopsworks/glassfish group to run service as",
          :type => 'string'

attribute "hopsworks/domains_dir",
          :description => "Installation directory for the glassfish domains",
          :type => 'string'

attribute "hopsworks/master/password",
          :description => "Web Application Server master password",
          :type => 'string'

attribute "download_url",
          :description => "URL for downloading binaries",
          :type => 'string'

# attribute "hopsworks/cert/password",
#           :description => "hopsworks/cert/password",
#           :type => 'string',
#           :default => "changeit"

attribute "karamel/cert/cn",
          :description => "Certificate Name",
          :type => 'string'

attribute "karamel/cert/o",
          :description => "organization",
          :type => 'string'

attribute "karamel/cert/ou",
          :description => "Organization unit",
          :type => 'string'

attribute "karamel/cert/l",
          :description => "Location",
          :type => 'string'

attribute "karamel/cert/s",
          :description => "City",
          :type => 'string'

attribute "karamel/cert/c",
          :description => "Country (2 letters)",
          :type => 'string'

attribute "glassfish/version",
          :description => "glassfish/version",
          :type => 'string'

attribute "glassfish/user",
          :description => "Install and run the glassfish server as this username",
          :type => 'string'

attribute "glassfish/group",
          :description => "glassfish/group",
          :type => 'string'

# attribute "glassfish/admin/port",
#           :description => "glassfish/admin/port",
#           :type => 'string'

# attribute "glassfish/port",
#           :description => "glassfish/port",
#           :type => 'string'


attribute "hopsworks/port",
          :description => "Port that webserver will listen on",
          :type => 'string'

attribute "hopsworks/max_mem",
          :description => "glassfish/max_mem",
          :type => 'string'

attribute "hopsworks/min_mem",
          :description => "glassfish/min_mem",
          :type => 'string'

attribute "hopsworks/max_stack_size",
          :description => "glassfish/max_stack_size",
          :type => 'string'


attribute "hopsworks/max_perm_size",
          :description => "glassfish/max_perm_size",
          :type => 'string'

attribute "kagent/enabled",
          :description =>  "Install kagent",
          :type => 'string'

attribute "hopsworks/reinstall",
          :description => "Enter 'true' if this is a reinstallation",
          :type => 'string'

attribute "hopsworks/war_url",
          :description => "Url for the hopsworks war file",
          :type => 'string'

attribute "hopsworks/yarn_default_quota_mins",
          :description => "Default number of CPU mins availble per project",
          :type => 'string'

attribute "hopsworks/hdfs_default_quota_gbs",
          :description => "Default amount in GB of available storage per project",
          :type => 'string'

attribute "hopsworks/max_num_proj_per_user",
          :description => "Maximum number of projects that can be created by each user",
          :type => 'string'

attribute "glassfish/package_url",
          :description => "Url for the Glassfish distribution zip file.",
          :type => 'string'

attribute "ndb/user",
          :description => "Username for the ndb services",
          :type => 'string'

attribute "ndb/group",
          :description => "Groupname for the ndb services",
          :type => 'string'

attribute "ndb/dir",
          :description => "ndb Installation directory.",
          :type => 'string'

attribute "kkafka/user",
          :description => "Username for the kkafka services",
          :type => 'string'

attribute "kkafka/group",
          :description => "Groupname for the kkafka services",
          :type => 'string'

attribute "kkafka/dir",
          :description => "kkafka Installation directory.",
          :type => 'string'

attribute "kzookeeper/user",
          :description => "Username for the kzookeeper services",
          :type => 'string'

attribute "kzookeeper/group",
          :description => "Groupname for the kzookeeper services",
          :type => 'string'

attribute "kzookeeper/dir",
          :description => "kzookeeper Installation directory.",
          :type => 'string'

attribute "livy/user",
          :description => "Username for the livy services",
          :type => 'string'

attribute "livy/group",
          :description => "Groupname for the livy services",
          :type => 'string'

attribute "livy/dir",
          :description => "livy Installation directory.",
          :type => 'string'

attribute "epipe/user",
          :description => "Username for the epipe services",
          :type => 'string'

attribute "epipe/group",
          :description => "Groupname for the epipe services",
          :type => 'string'

attribute "epipe/dir",
          :description => "epipe Installation directory.",
          :type => 'string'

attribute "elastic/user",
          :description => "Username for the elastic services",
          :type => 'string'

attribute "elastic/group",
          :description => "Groupname for the elastic services",
          :type => 'string'

attribute "elastic/dir",
          :description => "elastic Installation directory.",
          :type => 'string'

attribute "zeppelin/user",
          :description => "Username for the zeppelin services",
          :type => 'string'

attribute "zeppelin/group",
          :description => "Groupname for the zeppelin services",
          :type => 'string'

attribute "zeppelin/dir",
          :description => "zeppelin Installation directory.",
          :type => 'string'

attribute "kagent/user",
          :description => "Username for the kagent services",
          :type => 'string'

attribute "kagent/group",
          :description => "Groupname for the kagent services",
          :type => 'string'

attribute "kagent/dir",
          :description => "kagent Installation directory.",
          :type => 'string'

attribute "drelephant/user",
          :description => "Username for the drelephant services",
          :type => 'string'

attribute "drelephant/group",
          :description => "Groupname for the drelephant services",
          :type => 'string'

attribute "drelephant/dir",
          :description => "drelephant Installation directory.",
          :type => 'string'

attribute "dela/user",
          :description => "Username for the dela services",
          :type => 'string'

attribute "dela/group",
          :description => "Groupname for the dela services",
          :type => 'string'

attribute "dela/dir",
          :description => "dela Installation directory.",
          :type => 'string'

attribute "hadoop_spark/user",
          :description => "Username for the hadoop_spark services",
          :type => 'string'

attribute "hadoop_spark/group",
          :description => "Groupname for the hadoop_spark services",
          :type => 'string'

attribute "hadoop_spark/dir",
          :description => "hadoop_spark Installation directory.",
          :type => 'string'

attribute "flink/user",
          :description => "Username for the flink services",
          :type => 'string'

attribute "flink/group",
          :description => "Groupname for the flink services",
          :type => 'string'

attribute "flink/dir",
          :description => "flink Installation directory.",
          :type => 'string'

attribute "hops/dir",
          :description => "Ndb Installation directory.",
          :type => 'string'

attribute "hopsworks/kafka_num_replicas",
          :description => "Default number of replicas for Kafka Topics.",
          :type => 'string'

attribute "hopsworks/kafka_num_partitions",
          :description => "Default number of partitions for Kafka Topics.",
          :type => 'string'

attribute "hopsworks/file_preview_image_size",
          :description => "Maximum size in bytes of an image that can be previewed in DataSets",
          :type => 'string'

attribute "hopsworks/file_preview_txt_size",
          :description => "Maximum size in lines of file that can be previewed in DataSets",
          :type => 'string'

attribute "java/jdk_version",
          :display_name =>  "Jdk version",
          :type => 'string'

attribute "java/install_flavor",
          :display_name =>  "Oracle (default) or openjdk",
          :type => 'string'

attribute "vagrant",
          :description => "'true' to rewrite /etc/hosts, 'false' to disable vagrant /etc/hosts",
          :type => 'string'

attribute "services/enabled",
          :description => "Default 'false'. Set to 'true' to enable daemon services, so that they are started on a host restart.",
          :type => "string"

#########################################################################
#########################################################################
### BEGIN GENERATED CONTENT
