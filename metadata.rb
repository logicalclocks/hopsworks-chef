
name             'hopsworks'
maintainer       "Jim Dowling"
maintainer_email "jdowling@kth.se"
license          "Apache v2.0"
description      "Installs/Configures the HopsHub Dashboard"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1"

%w{ ubuntu debian centos rhel }.each do |os|
  supports os
end

depends 'glassfish'
depends 'ndb'
depends 'kagent'
depends 'hops'
depends 'ark'
depends 'elastic'
depends 'spark'
depends 'flink'
depends 'zeppelin'
#depends 'sudo'

recipe  "hopsworks::install", "Installs HopsHub/Glassfish"

#link:Click <a target='_blank' href='http://%host%:8080/hopsworks'>here</a> to launch hopsworks in your browser (http)
recipe  "hopsworks", "Installs HopsWorks war file, starts glassfish+application."

#######################################################################################
# Required Attributes
#######################################################################################


attribute "hopsworks/default/user",
          :description => "Username for the first (default) HopsWorks account",
          :type => 'string',
          :required => "required"

attribute "hopsworks/default/password",
          :description => "Password for the first (default) HopsWorks account",
          :type => 'string',
          :required => "required"

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


attribute "hopsworks/gmail/email",
          :description => "Email address for gmail account",
          :required => "required",
          :type => 'string'

attribute "hopsworks/gmail/password",
          :description => "Password for gmail account",
          :required => "required",
          :type => 'string'


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

attribute "hopsworks/twofactor_auth",
          :description => "hopsworks/twofactor_auth",
          :type => 'string'

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
          :description => "glassfish/user",
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


attribute "glassfish/max_mem",
          :description => "glassfish/max_mem",
          :type => 'string'

attribute "glassfish/min_mem",
          :description => "glassfish/min_mem",
          :type => 'string'

attribute "glassfish/max_stack_size",
          :description => "glassfish/max_stack_size",
          :type => 'string'


attribute "glassfish/max_perm_size",
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

attribute "twofactor_auth",
          :description => "Set to 'true' to enable two-factor authentication",
          :type => 'string'
