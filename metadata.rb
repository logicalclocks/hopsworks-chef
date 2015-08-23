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

recipe  "hopsworks::install", "Installs HopsHub/Glassfish"

#link:Click <a target='_blank' href='http://%host%:8080/hopsworks'>here</a> to launch hopsworks in your browser (http)
#link:Click <a target='_blank' href='https://%host%:8181/hopsworks'>here</a> to launch hopsworks in your browser (https)
recipe  "hopsworks", "Installs HopsWorks war file, starts glassfish+application."


attribute "hopsworks/admin/user",
          :description => "Username for Hops Admin account",
          :type => 'string',
          :required => "required"

attribute "hopsworks/admin/password",
          :description => "hopsworks/admin/password",
          :type => 'string',
          :required => "required"

attribute "karamel/master/password",
          :description => "karamel/master/password",
          :type => 'string',
          :default => "changeit"

attribute "hopsworks/cert/password",
          :description => "hopsworks/cert/password",
          :type => 'string',
          :default => "changeit"

attribute "hopsworks/twofactor_auth",
          :description => "hopsworks/twofactor_auth",
          :type => 'string',
          :default => "false"

attribute "karamel/cert/cn",
          :description => "Certificate Name",
          :type => 'string',
          :default => "hops.kth.se"

attribute "karamel/cert/o",
          :description => "organization",
          :type => 'string',
          :default => "kth"

attribute "karamel/cert/ou",
          :description => "Organization unit",
          :type => 'string',
          :default => "ict"

attribute "karamel/cert/l",
          :description => "Location",
          :type => 'string',
          :default => "kista"

attribute "karamel/cert/s",
          :description => "City",
          :type => 'string',
          :default => "stockholm"

attribute "karamel/cert/c",
          :description => "Country (2 letters)",
          :type => 'string',
          :default => "se"

attribute "glassfish/version",
          :description => "glassfish/version",
          :type => 'string',
          :default => '4.1'

attribute "glassfish/user",
          :description => "glassfish/user",
          :type => 'string',
          :default => "glassfish"

attribute "glassfish/group",
          :description => "glassfish/group",
          :type => 'string',
          :default => "glassfish-admin"

attribute "glassfish/admin/port",
          :description => "glassfish/admin/port",
          :type => 'string',
          :default => 4848

attribute "glassfish/port",
          :description => "glassfish/port",
          :type => 'string',
          :default => 8080

attribute "glassfish/max_mem",
          :description => "glassfish/max_mem",
          :type => 'string',
          :default => 4000

attribute "glassfish/min_mem",
          :description => "glassfish/min_mem",
          :type => 'string',
          :default => 2500

attribute "glassfish/max_stack_size",
          :description => "glassfish/max_stack_size",
          :type => 'string',
          :default => 512

attribute "glassfish/max_perm_size",
          :description => "glassfish/max_perm_size",
          :type => 'string',
          :default => 1024

attribute "kagent/enabled",
          :description =>  "Install kagent",
          :type => 'string',
          :default => "false"

attribute "hopsworks/gmail/email",
          :description => "Email address for gmail account",
          :required => "required",
          :type => 'string'

attribute "hopsworks/gmail/password",
          :description => "Password for gmail account",
          :required => "required",
          :type => 'string'
