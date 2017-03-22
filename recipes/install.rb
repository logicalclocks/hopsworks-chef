require 'json'
require 'base64'

private_ip=my_private_ip()
username=node.hopsworks.admin.user
password=node.hopsworks.admin.password
domain_name="domain1"
domains_dir = node.glassfish.domains_dir
admin_port = node.glassfish.admin.port
web_port = node.glassfish.port
mysql_user=node.mysql.user
mysql_password=node.mysql.password
mysql_host = my_private_ip()
password_file = "#{domains_dir}/#{domain_name}_admin_passwd"

case node.platform
when "ubuntu"
 if node.platform_version.to_f <= 14.04
   node.override.hopsworks.systemd = "false"
 end
end

if node.hopsworks.systemd === "true" 
  systemd = true
else
  systemd = false
end

group node.hopsworks.group do
  action :create
  not_if "getent group #{node.hopsworks.group}"
end

user node.hopsworks.user do
  home "/home/#{node.hopsworks.user}"
  gid node.hopsworks.group
  action :create
  shell "/bin/bash"
  manage_home true
  not_if "getent passwd #{node.hopsworks.user}"
end


directory node.hopsworks.dir  do
  owner node.hopsworks.user
  group node.hopsworks.group
  mode "755"
  action :create
  not_if "test -d #{node.hopsworks.dir}"

end

directory node.hopsworks.domains_dir  do
  owner node.hopsworks.user
  group node.hopsworks.group
  mode "755"
  action :create
  recursive true
  not_if "test -d #{node.hopsworks.domains_dir}"
end


node.override = {
  'java' => {
    'install_flavor' => node.java.install_flavor,
    'jdk_version' => node.java.jdk_version,
    'oracle' => {
      'accept_oracle_download_terms' => true
    }
  },
  'glassfish' => {
    'version' => node.glassfish.version,
    'domains' => {
      domain_name => {
        'config' => {
          'systemd_enabled' => systemd,
          'systemd_start_timeout' => 240,
          'min_memory' => node.glassfish.min_mem,
          'max_memory' => node.glassfish.max_mem,
          'max_perm_size' => node.glassfish.max_perm_size,
          'max_stack_size' => node.glassfish.max_stack_size, 
          'port' => web_port,
          'admin_port' => admin_port,
          'username' => username,
          'password' => password,
          'master_password' => node.hopsworks.master.password,
          'remote_access' => false,
          'secure' => false,
          'jvm_options' => ["-DHADOOP_HOME=#{node.hops.dir}/hadoop", "-DHADOOP_CONF_DIR=#{node.hops.dir}/hadoop/etc/hadoop", '-Dcom.sun.enterprise.tools.admingui.NO_NETWORK=true', '-Dlog4j.configuration=file:///${com.sun.aas.instanceRoot}/config/log4j.properties']
        },
        'extra_libraries' => {
          'jdbcdriver' => {
            'type' => 'common',
            'url' => node.hopsworks.mysql_connector_url
          }
        },
        'threadpools' => {
          'thread-pool-1' => {
            'maxthreadpoolsize' => 200,
            'minthreadpoolsize' => 5,
            'idletimeout' => 900,
            'maxqueuesize' => 4096
          },
          'http-thread-pool' => {
            'maxthreadpoolsize' => 200,
            'minthreadpoolsize' => 5,
            'idletimeout' => 900,
            'maxqueuesize' => 4096
          },
          'admin-pool' => {
            'maxthreadpoolsize' => 40,
            'minthreadpoolsize' => 5,
            'maxqueuesize' => 256
          }
        },
        'jdbc_connection_pools' => {
          'hopsworksPool' => {
            'config' => {
              'datasourceclassname' => 'com.mysql.jdbc.jdbc2.optional.MysqlDataSource',
              'restype' => 'javax.sql.DataSource',
              'isconnectvalidatereq' => 'true',
              'validationmethod' => 'auto-commit',
              'ping' => 'true',
              'description' => 'Hopsworks Connection Pool',
              'properties' => {
                'Url' => "jdbc:mysql://#{mysql_host}:3306/",
                'User' => mysql_user,
                'Password' => mysql_password
              }
            },
            'resources' => {
              'jdbc/hopsworks' => {
                'description' => 'Resource for Hopsworks Pool',
              }
            }
          },
          'ejbTimerPool' => {
            'config' => {
              'datasourceclassname' => 'com.mysql.jdbc.jdbc2.optional.MysqlDataSource',
              'restype' => 'javax.sql.DataSource',
              'isconnectvalidatereq' => 'true',

              'validationmethod' => 'auto-commit',
              'ping' => 'true',
              'description' => 'Hopsworks Connection Pool',
              'properties' => {
                'Url' => "jdbc:mysql://#{mysql_host}:3306/glassfish_timers",
                'User' => mysql_user,
                'Password' => mysql_password
              }
            },
            'resources' => {
              'jdbc/hopsworksTimers' => {
                'description' => 'Resource for Hopsworks EJB Timers Pool',
              }
            }
          }
        }
      }
    }
  }
}



installed = "#{node.glassfish.base_dir}/.installed"
if ::File.exists?( "#{installed}" ) == false

  package 'openssl'

  include_recipe 'glassfish::default'
  include_recipe 'glassfish::attribute_driven_domain'

  file "#{installed}" do # Mark that glassfish is installed
    owner node.glassfish.user
  end

  cauth = File.basename(node.hopsworks.cauth_url)

  remote_file "#{node.glassfish.domains_dir}/#{domain_name}/lib/#{cauth}"  do
    user node.glassfish.user
    group node.glassfish.group
    source node.hopsworks.cauth_url
    mode 0755
    action :create_if_missing
  end

end


# If the install.rb recipe failed and is re-run, install_dir needs to reset it
if node.glassfish.install_dir.include?("versions") == false
  node.override.glassfish.install_dir = "#{node.glassfish.install_dir}/glassfish/versions/current"
end



#
# This code is to enable ssh access
#
#node.default.authorization.sudo.include_sudoers_d = true
#node.default.authorization.sudo.passwordless = true
#include_recipe 'sudo'
#sudo 'glassfish' do
#  user    node.glassfish].user]
#  commands  ['/srv/mkuser.sh', '/usr/sbin/deluser', '/usr/mount', '/usr/umount']
#  nopasswd   true
#end



 template "#{node.glassfish.domains_dir}/#{domain_name}/docroot/404.html" do
    source "404.html.erb"
    owner node.glassfish.user
    mode 0777
    variables({
                :org_name => node.hopsworks.cert.o
              })
    action :create
 end 

cookbook_file"#{node.glassfish.domains_dir}/#{domain_name}/docroot/obama-smoked-us.gif" do
  source 'obama-smoked-us.gif'
  owner node.glassfish.user
  group node.glassfish.group
  mode '0755'
  action :create
end


# if node.glassfish.port == 80
#   authbind_port "AuthBind GlassFish Port 80" do
#     port 80
#     user node.glassfish.user
#   end
# end


case node.platform
when "rhel"
service_name = "glassfish-#{domain_name}"

file "/etc/systemd/system/#{service_name}.service" do
  owner "root"
  action :delete
end


  template "/usr/lib/systemd/system/#{service_name}.service" do
    source 'systemd.service.erb'
    mode '0741'
    cookbook 'hopsworks'
    variables(
              :start_domain_command => "#{asadmin} start-domain #{password_file} --verbose false --debug false --upgrade false #{domain_name}",
              :restart_domain_command => "#{asadmin} restart-domain #{password_file} #{domain_name}",
              :stop_domain_command => "#{asadmin} stop-domain #{password_file} #{domain_name}",
              :authbind => requires_authbind,
              :listen_ports => [admin_port, node.glassfish.port])
  end
end


if systemd == true
  directory "/etc/systemd/system/glassfish-#{domain_name}.service.d" do
    owner "root"
    group "root"
    mode "755"
    action :create
  end

  template "/etc/systemd/system/glassfish-#{domain_name}.service.d/limits.conf" do
    source "limits.conf.erb"
    owner "root"
    mode 0774
    action :create
  end 

    hopsworks_grants "reload_systemd" do
      tables_path  ""
      views_path ""
      rows_path  ""
      action :reload_systemd
    end 

end

directory "#{node.glassfish.domains_dir}/#{domain_name}/config/ca/" do
    owner node.glassfish.user
    group node.glassfish.group
    mode "700"
    action :create
  end

dirs = %w{certs crl newcerts private intermediate}

for d in dirs 
  directory "#{node.glassfish.domains_dir}/#{domain_name}/config/ca/#{d}" do
    owner node.glassfish.user
    group node.glassfish.group
    mode "700"
    action :create
  end
end

int_dirs = %w{certs crl csr newcerts private}

for d in int_dirs 
  directory "#{node.glassfish.domains_dir}/#{domain_name}/config/ca/intermediate/#{d}" do
    owner node.glassfish.user
    group node.glassfish.group
    mode "700"
    action :create
  end
end

template "#{node.glassfish.domains_dir}/#{domain_name}/config/ca/openssl-ca.cnf" do
  source "caopenssl.cnf.erb"
  owner node.glassfish.user
  mode "600"
  variables({
    :ca_dir =>  "#{node.glassfish.domains_dir}/#{domain_name}/config/ca"
  })
  action :create
end 

template "#{node.glassfish.domains_dir}/#{domain_name}/config/ca/intermediate/openssl-intermediate.cnf" do
  source "intermediateopenssl.cnf.erb"
  owner node.glassfish.user
  mode "600"
    variables({
                :int_ca_dir =>  "#{node.glassfish.domains_dir}/#{domain_name}/config/ca/intermediate"
              })
  action :create
end 

template "#{node.glassfish.domains_dir}/#{domain_name}/config/ca/intermediate/createusercerts.sh" do
  source "createusercerts.sh.erb"
  owner "root"
  group node.glassfish.group
  mode "510"
 variables({
                :int_ca_dir =>  "#{node.glassfish.domains_dir}/#{domain_name}/config/ca/intermediate/"
              })
  action :create
end

template "#{node.glassfish.domains_dir}/#{domain_name}/config/ca/intermediate/deleteusercerts.sh" do
  source "deleteusercerts.sh.erb"
  owner "root"
  group node.glassfish.group
  mode "510"
 variables({
                :int_ca_dir =>  "#{node.glassfish.domains_dir}/#{domain_name}/config/ca/intermediate/"
              })
  action :create
end

template "#{node.glassfish.domains_dir}/#{domain_name}/config/ca/intermediate/deleteprojectcerts.sh" do
  source "deleteprojectcerts.sh.erb"
  owner "root"
  group node.glassfish.group
  mode "510"
 variables({
                :int_ca_dir =>  "#{node.glassfish.domains_dir}/#{domain_name}/config/ca/intermediate/"
              })
  action :create
end

template "#{node.glassfish.domains_dir}/#{domain_name}/bin/ndb_backup.sh" do
  source "ndb_backup.sh.erb"
  owner node.glassfish.user
  group node.glassfish.group
  mode "754"
  action :create
end



template "/etc/sudoers.d/glassfish" do
  source "glassfish_sudoers.erb"
  owner "root"
  group "root"
  mode "0440"
  variables({
                :user => node.glassfish.user,
                :int_sh_dir =>  "#{node.glassfish.domains_dir}/#{domain_name}/config/ca/intermediate/createusercerts.sh",
                :delete_usercert =>  "#{node.glassfish.domains_dir}/#{domain_name}/config/ca/intermediate/deleteusercerts.sh",
                :delete_projectcert =>  "#{node.glassfish.domains_dir}/#{domain_name}/config/ca/intermediate/deleteprojectcerts.sh",
                :ndb_backup =>  "#{node.glassfish.domains_dir}/#{domain_name}/bin/ndb_backup.sh"                
              })
  action :create
end  

# Replace sysv with our version. It increases the max number of open files limit (ulimit -n)
case node.platform
when "ubuntu"
  file "/etc/init.d/glassfish-#{domain_name}" do
    owner "root"
    action :delete
  end

 template "/etc/init.d/glassfish-#{domain_name}" do
    source "glassfish.erb"
    owner "root"
    mode 0744
    action :create
  variables({
       :domain_name =>  domain_name,
       :password_file => password_file
   })

 end 

end

