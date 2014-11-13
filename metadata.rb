name             'hopshub'
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
depends 'collectd'
depends 'kagent'
#depends 'runit'

attribute "hopshub/private_ips",
:display_name => "HopsHub private IP addresses",
:description => "List of private IP addresses of HopsHub",
:type => 'array',
:default => ""

attribute "hopshub/public_ips",
:display_name => "HopsHub public IP addresses",
:description => "List of public IP addresses of HopsHub",
:type => 'array',
:default => ""
