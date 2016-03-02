name             "hopsworks"
maintainer       "Jim Dowling"
maintainer_email "jdowling@kth.se"
license          "Apache v2.0"
description      "Installs/Configures the HopsHub Dashboard"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.0"

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
#depends 'sudo'
depends 'compat_resource'
depends 'ulimit'
depends 'authbind'
depends 'apache_hadoop'

#link:Click <a target='_blank' href='https://%host%:4848'>here</a> to launch Glassfish in your browser (http)
recipe  "hopsworks::install", "Installs Glassfish"

#link:Click <a target='_blank' href='http://%host%:8080/hopsworks'>here</a> to launch hopsworks in your browser (http)
recipe  "hopsworks", "Installs HopsWorks war file, starts glassfish+application."

recipe  "hopsworks::dev", "Installs development libraries needed for HopsWorks development."

recipe  "hopsworks::letsencypt", "Given a glassfish installation and a letscrypt installation, update glassfish's key."

#######################################################################################
# Required Attributes
#######################################################################################


attribute "hopsworks/twofactor_auth",
          :description => "twofactor_auth (default: false)",
          :type => 'string',
          :required => "required"

attribute "hopsworks/gmail/email",
          :description => "Email address for gmail account",
          :required => "required",
          :type => 'string'

attribute "hopsworks/gmail/password",
          :description => "Password for gmail account",
          :required => "required",
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

attribute "hopsworks/master/password",
          :description => "Web Application Server master password",
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

attribute "ndb/dir",
          :description => "Ndb Installation directory.",
          :type => 'string'

attribute "hops/dir",
          :description => "Ndb Installation directory.",
          :type => 'string'

attribute "hadoop_spark/dir",
          :description => "Installation directory.",
          :type => 'string'


