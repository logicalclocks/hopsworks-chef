require 'json'
require 'base64'
require 'digest'

my_ip = my_private_ip()
username=node['hopsworks']['admin']['user']
password=node['hopsworks']['admin']['password']
domain_name="domain1"
domains_dir = node['hopsworks']['domains_dir']
theDomain="#{domains_dir}/#{domain_name}"
admin_port = node['glassfish']['admin']['port']
web_port = node['glassfish']['port']
mysql_user=node['mysql']['user']
mysql_password=node['mysql']['password']
password_file = "#{theDomain}_admin_passwd"

bash "systemd_reload_for_glassfish_failures" do
  user "root"
  ignore_failure true
  code <<-EOF
    systemctl stop glassfish-#{domain_name}
    systemctl daemon-reload
  EOF
end


case node['platform_family']
when "redhat"
  if node['glassfish']['port'] == 80
    bash "authbind-centos" do
      user "root"
      code <<-EOF
         cd #{Chef::Config['file_cache_path']}
         rm -f authbind_2.1.1.tar.gz
         wget #{node['download_url']}/authbind_2.1.1.tar.gz
         tar authbind_2.1.1.tar.gz
         cd authbind-2.1.1
         make
         make install
         ln -s /usr/local/bin/authbind /usr/bin/authbind
         mkdir -p /etc/authbind/byport
         touch /etc/authbind/byport/80
         chmod 550 /etc/authbind/byport/80
         touch /etc/authbind/byport/443
         chmod 550 /etc/authbind/byport/443
     EOF
       not_if { ::File.exists?("/usr/bin/authbind") }
    end
  end
end



if node['hopsworks']['systemd'] == "true"
  systemd = true
else
  systemd = false
end

group node['hopsworks']['group'] do
  action :create
  not_if "getent group #{node['hopsworks']['group']}"
end

group node['jupyter']['group'] do
  action :create
  not_if "getent group #{node['jupyter']['group']}"
end

group node['tfserving']['group'] do
  action :create
  not_if "getent group #{node['tfserving']['group']}"
end

#
# hdfs superuser group is 'hdfs'
#
group node['hops']['hdfs']['user'] do
  action :create
  not_if "getent group #{node['hops']['hdfs']['user']}"
end

user node['hopsworks']['user'] do
  home "/home/#{node['hopsworks']['user']}"
  gid node['hopsworks']['group']
  action :create
  shell "/bin/bash"
  manage_home true
  not_if "getent passwd #{node['hopsworks']['user']}"
end

group node['jupyter']['group'] do
  action :modify
  members ["#{node['hopsworks']['user']}"]
  append true
end

group node['tfserving']['group'] do
  action :modify
  members ["#{node['hopsworks']['user']}"]
  append true
end
group node['jupyter']['group'] do
  action :modify
  members ["#{node['hopsworks']['user']}"]
  append true
end

group node['conda']['group'] do
  action :modify
  members ["#{node['hopsworks']['user']}"]
  append true
end

# Add to the hdfs superuser group
group node['hops']['hdfs']['user'] do
  action :modify
  members ["#{node['hopsworks']['user']}"]
  append true
end

user node['jupyter']['user'] do
  home node['jupyter']['base_dir']
  gid node['jupyter']['group']
  action :create
  shell "/bin/bash"
  manage_home true
  not_if "getent passwd #{node['jupyter']['user']}"
end

user node['tfserving']['user'] do
  gid node['tfserving']['group']
  action :create
  shell "/bin/bash"
  manage_home true
  not_if "getent passwd #{node['tfserving']['user']}"
end

group node['kagent']['certs_group'] do
  action :modify
  members ["#{node['hopsworks']['user']}"]
  append true
end

group node['hops']['group'] do
  action :modify
  members ["#{node['hopsworks']['user']}", "#{node['jupyter']['user']}"]
  append true
end

#update permissions of base_dir to 770
directory node['jupyter']['base_dir']  do
  owner node['jupyter']['user']
  group node['jupyter']['group']
  mode "770"
  action :create
end

directory node['hopsworks']['dir']  do
  owner node['hopsworks']['user']
  group node['hopsworks']['group']
  mode "755"
  action :create
  not_if "test -d #{node['hopsworks']['dir']}"
end

directory domains_dir  do
  owner node['hopsworks']['user']
  group node['hopsworks']['group']
  mode "750"
  action :create
  not_if "test -d #{domains_dir}"
end


# For unzipping files

case node['platform_family']
when "debian"

  if node['platform_version'].to_f <= 14.04
    node.override['hopsworks']['systemd'] = "false"
  end
  package "dtrx"
  package "libkrb5-dev"

when "redhat"
  package "krb5-libs"

  remote_file "#{Chef::Config['file_cache_path']}/dtrx.tar.gz" do
    user node['glassfish']['user']
    group node['glassfish']['group']
    source node['download_url'] + "/#{node['dtrx']['version']}"
    mode 0755
    action :create
  end

  bash "unpack_dtrx" do
    user "root"
    code <<-EOF
    set -e
    cd #{Chef::Config['file_cache_path']}
    tar -xzf dtrx.tar.gz
    cd dtrx-7.1
    python setup.py install --prefix=/usr/local
  EOF
    not_if "which dtrx"
  end
end




node.override = {
  'java' => {
    'install_flavor' => node['java']['install_flavor'],
    'jdk_version' => node['java']['jdk_version'],
    'oracle' => {
      'accept_oracle_download_terms' => true
    }
  },
  'glassfish' => {
    'version' => node['glassfish']['version'],
    'domains' => {
      domain_name => {
        'config' => {
          'systemd_enabled' => systemd,
          'systemd_start_timeout' => 900,
          'min_memory' => node['glassfish']['min_mem'],
          'max_memory' => node['glassfish']['max_mem'],
          'max_perm_size' => node['glassfish']['max_perm_size'],
          'max_stack_size' => node['glassfish']['max_stack_size'],
          'port' => web_port,
          'admin_port' => admin_port,
          'username' => username,
          'password' => password,
          'master_password' => node['hopsworks']['master']['password'],
          'remote_access' => false,
          'secure' => false,
          'jvm_options' => ["-DHADOOP_HOME=#{node['hops']['dir']}/hadoop", "-DHADOOP_CONF_DIR=#{node['hops']['dir']}/hadoop/etc/hadoop", '-Dcom.sun.enterprise.tools.admingui.NO_NETWORK=true', '-Dlog4j.configuration=file:///${com.sun.aas.instanceRoot}/config/log4j.properties']
        },
        'extra_libraries' => {
          'jdbcdriver' => {
            'type' => 'common',
            'url' => node['hopsworks']['mysql_connector_url']
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
        'managed_thread_factories' => {
          'concurrent/hopsThreadFactory' => {
            'threadpriority' => 12,
            'description' => 'Hopsworks Thread Factory'
          }
        },
        'managed_executor_services' => {
          'concurrent/hopsExecutorService' => {
            'threadpriority' => 12,
            'description' => 'Hopsworks Executor Service'
          }
        },
        'managed_scheduled_executor_services' => {
          'concurrent/hopsScheduledExecutorService' => {
            'corepoolsize' => 12,
            'description' => 'Hopsworks Executor Service'
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
                'Url' => "jdbc:mysql://#{my_ip}:3306/",
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
                'Url' => "jdbc:mysql://#{my_ip}:3306/glassfish_timers",
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


include_recipe 'glassfish::default'
package 'openssl'

if ::File.directory?( "#{theDomain}/lib" ) == false
  include_recipe 'glassfish::attribute_driven_domain'
end

cauth = File.basename(node['hopsworks']['cauth_url'])

remote_file "#{theDomain}/lib/#{cauth}"  do
  user node['glassfish']['user']
  group node['glassfish']['group']
  source node['hopsworks']['cauth_url']
  mode 0755
  action :create_if_missing
end



# If the install.rb recipe failed and is re-run, install_dir needs to reset it
if node['glassfish']['install_dir'].include?("versions") == false
  node.override['glassfish']['install_dir'] = "#{node['glassfish']['install_dir']}/glassfish/versions/current"
end


template "#{theDomain}/docroot/404.html" do
  source "404.html.erb"
  owner node['glassfish']['user']
  mode 0777
  variables({
              :org_name => node['hopsworks']['org_name']
            })
  action :create
end

cookbook_file"#{theDomain}/docroot/obama-smoked-us.gif" do
  source 'obama-smoked-us.gif'
  owner node['glassfish']['user']
  group node['glassfish']['group']
  mode '0755'
  action :create_if_missing
end

case node['platform']
 when 'debian', 'ubuntu'
 if node['glassfish']['port'] == 80
   authbind_port "AuthBind GlassFish Port 80" do
     port 80
     user node['glassfish']['user']
   end
 end
end


include_recipe "hopsworks::authbind"


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

ulimit_domain node['hopsworks']['user'] do
  rule do
    item :memlock
    type :soft
    value "unlimited"
  end
  rule do
    item :memlock
    type :hard
    value "unlimited"
  end
end




  hopsworks_grants "reload_systemd" do
    tables_path  ""
    views_path ""
    rows_path  ""
    action :reload_systemd
  end

end

ca_dir = node['certs']['dir']

directory ca_dir do
  owner node['glassfish']['user']
  group node['kagent']['certs_group']
  mode "750"
  action :create
end

master_password_digest = Digest::SHA256.hexdigest node['hopsworks']['encryption_password']

file "#{ca_dir}/encryption_master_password" do
  content "#{master_password_digest}"
  mode "0700"
  owner node['glassfish']['user']
  group node['glassfish']['group']
end

directory "#{ca_dir}/transient" do
  owner node['glassfish']['user']
  group node['kagent']['certs_group']
  mode "750"
  action :create
end

dirs = %w{certs crl newcerts private intermediate}

for d in dirs
  directory "#{ca_dir}/#{d}" do
    owner node['glassfish']['user']
    group node['glassfish']['group']
    mode "700"
    action :create
  end
end

int_dirs = %w{certs crl csr newcerts private}

for d in int_dirs
  directory "#{ca_dir}/intermediate/#{d}" do
    owner node['glassfish']['user']
    group node['glassfish']['group']
    mode "700"
    action :create
  end
end

template "#{ca_dir}/openssl-ca.cnf" do
  source "caopenssl.cnf.erb"
  owner node['glassfish']['user']
  mode "600"
  variables({
              :ca_dir =>  "#{ca_dir}"
            })
  action :create
end

template "#{ca_dir}/intermediate/openssl-intermediate.cnf" do
  source "intermediateopenssl.cnf.erb"
  owner node['glassfish']['user']
  mode "600"
  variables({
              :int_ca_dir =>  "#{ca_dir}/intermediate"
            })
  action :create
end

template "#{ca_dir}/intermediate/createusercerts.sh" do
  source "createusercerts.sh.erb"
  owner "root"
  group node['glassfish']['group']
  mode "510"
  variables({
              :int_ca_dir =>  "#{ca_dir}/intermediate/"
            })
  action :create
end

template "#{ca_dir}/intermediate/deleteusercerts.sh" do
  source "deleteusercerts.sh.erb"
  owner "root"
  group node['glassfish']['group']
  mode "510"
  variables({
              :int_ca_dir =>  "#{ca_dir}/intermediate/"
            })
  action :create
end

template "#{ca_dir}/intermediate/deleteprojectcerts.sh" do
  source "deleteprojectcerts.sh.erb"
  owner "root"
  group node['glassfish']['group']
  mode "510"
  variables({
              :int_ca_dir =>  "#{ca_dir}/intermediate/"
            })
  action :create
end

template "#{theDomain}/bin/ndb_backup.sh" do
  source "ndb_backup.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  mode "754"
  action :create
end

template "#{theDomain}/bin/jupyter.sh" do
  source "jupyter.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  mode "550"
  action :create
end

template "#{theDomain}/bin/jupyter-kernel-install.sh" do
  source "jupyter-kernel-install.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  mode "550"
  action :create
end


template "#{theDomain}/bin/jupyter-project-cleanup.sh" do
  source "jupyter-project-cleanup.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  mode "550"
  action :create
end

template "#{theDomain}/bin/jupyter-kill.sh" do
  source "jupyter-kill.sh.erb"
  owner node['glassfish']['user']
  group node['jupyter']['group']
  mode "550"
  action :create
end

template "#{theDomain}/bin/jupyter-stop.sh" do
  source "jupyter-stop.sh.erb"
  owner node['glassfish']['user']
  group node['jupyter']['group']
  mode "550"
  action :create
end

template "#{theDomain}/bin/jupyter-launch.sh" do
  source "jupyter-launch.sh.erb"
  owner node['glassfish']['user']
  group node['jupyter']['group']
  mode "550"
  action :create
end

template "#{theDomain}/bin/tfserving.sh" do
  source "tfserving.sh.erb"
  owner node['glassfish']['user']
  group node['tfserving']['group']
  mode "550"
  action :create
end

template "#{theDomain}/bin/tfserving-kill.sh" do
  source "tfserving-kill.sh.erb"
  owner node['glassfish']['user']
  group node['tfserving']['group']
  mode "550"
  action :create
end

template "#{theDomain}/bin/tfserving-kill.sh" do
  source "tfserving-kill.sh.erb"
  owner node['glassfish']['user']
  group node['tfserving']['group']
  mode "550"
  action :create
end

template "#{theDomain}/bin/anaconda-prepare.sh" do
  source "anaconda-prepare.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  mode "550"
  action :create
end

template "#{theDomain}/bin/condaexport.sh" do
  source "condaexport.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  mode "550"
  action :create
end

template "#{theDomain}/bin/anaconda-rsync.sh" do
  source "anaconda-rsync.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  mode "550"
  action :create
end

template "#{theDomain}/bin/kagent-restart.sh" do
  source "kagent-restart.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  mode "500"
  action :create
end


command=""
case node['platform']
 when 'debian', 'ubuntu'
   command='tensorflow_model_server'
 when 'redhat', 'centos', 'fedora'
   command='/opt/serving/bazel-bin/tensorflow_serving/model_servers/tensorflow_model_server'
end


template "#{theDomain}/bin/tfserving-launch.sh" do
  source "tfserving-launch.sh.erb"
  owner node['glassfish']['user']
  group node['tfserving']['group']
  mode "550"
  variables({
     :command => command
  })
  action :create
end

template "#{theDomain}/bin/zip-hdfs-files.sh" do
  source "zip-hdfs-files.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  mode "550"
  action :create
end

template "#{theDomain}/bin/zip-background.sh" do
  source "zip-background.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  mode "550"
  action :create
end

template "#{theDomain}/bin/unzip-hdfs-files.sh" do
  source "unzip-hdfs-files.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  mode "550"
  action :create
end

template "#{theDomain}/bin/unzip-background.sh" do
  source "unzip-background.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  mode "550"
  action :create
end

template "#{theDomain}/bin/global-ca-sign-csr.sh" do
  source "global-ca-sign-csr.sh.erb"
  owner node['glassfish']['user']
  mode 0550
  action :create
end

template "#{theDomain}/bin/ca-keystore.sh" do
  source "ca-keystore.sh.erb"
  owner node['glassfish']['user']
  mode 0550
  action :create
  variables({
         :directory => node["hopssite"]["keystore_dir"],
  })
end

template "#{theDomain}/bin/start-llap.sh" do
  source "start-llap.sh.erb"
  owner node['glassfish']['user']
  group node['hive2']['group']
  mode 0550
  action :create
end

template "#{theDomain}/bin/dump_web_logs_to_hdfs.sh" do
  source "dump_web_logs_to_hdfs.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  mode 0700
  action :create
  variables({
              :weblogs_dir => "#{theDomain}/logs/access",
              :hadoop_home => node['hops']['base_dir'],
              :remote_weblogs_dir => "#{node['hops']['hdfs']['user_home']}/#{node['glassfish']['user']}/webserver_logs"
            })
end

template "/etc/sudoers.d/glassfish" do
  source "glassfish_sudoers.erb"
  owner "root"
  group "root"
  mode "0440"
  variables({
              :user => node['glassfish']['user'],
              :int_sh_dir =>  "#{ca_dir}/intermediate/createusercerts.sh",
              :delete_usercert =>  "#{ca_dir}/intermediate/deleteusercerts.sh",
              :delete_projectcert =>  "#{ca_dir}/intermediate/deleteprojectcerts.sh",
              :ndb_backup =>  "#{theDomain}/bin/ndb_backup.sh",
              :jupyter =>  "#{theDomain}/bin/jupyter.sh",
              :tfserving =>  "#{theDomain}/bin/tfserving.sh",
              :conda_export =>  "#{theDomain}/bin/condaexport.sh",
              :tensorboard =>  "#{theDomain}/bin/tensorboard.sh",
              :jupyter_cleanup =>  "#{theDomain}/bin/jupyter-project-cleanup.sh",
              :jupyter_kernel =>  "#{theDomain}/bin/jupyter-install-kernel.sh",
              :global_ca_sign =>  "#{theDomain}/bin/global-ca-sign-csr.sh",
              :ca_keystore => "#{theDomain}/bin/ca-keystore.sh",
              :hive_user => node['hive2']['user'],
              :anaconda_prepare => "#{theDomain}/bin/anaconda-prepare.sh",
              :start_llap => "#{theDomain}/bin/start-llap.sh"
            })
  action :create
end

# Replace sysv with our version. It increases the max number of open files limit (ulimit -n)
case node['platform']
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



#
# Jupyter Configuration
#


# Hopsworks user should own the directory so that hopsworks code
# can create the template files needed for Jupyter.
# Hopsworks will use a sudoer script to launch jupyter as the 'jupyter' user.
# The jupyter user will be able to read the files and write to the directories due to group permissions

user node["jupyter"]["user"] do
  home node["jupyter"]["base_dir"]
  gid node["jupyter"]["group"]
  action :create
  shell "/bin/bash"
  manage_home true
  not_if "getent passwd #{node["jupyter"]["user"]}"
end

#update permissions of base_dir to 770
directory node["jupyter"]["base_dir"]  do
  owner node["jupyter"]["user"]
  group node["jupyter"]["group"]
  mode "770"
  action :create
end

bash "python_openssl" do
  user "root"
  code <<-EOF
    pip install pyopenssl
    # --upgrade
  EOF
end


directory node["hopssite"]["certs_dir"] do
  owner node["glassfish"]["user"]
  group node['kagent']['certs_group']
  mode "750"
  action :create
end

directory node["hopssite"]["keystore_dir"] do
  owner node["glassfish"]["user"]
  mode "750"
  action :create
end

template "#{theDomain}/config/ca.ini" do
  source "ca.ini.erb"
  owner node['glassfish']['user']
  mode 0750
  action :create
end

template "#{theDomain}/bin/csr-ca.py" do
  source "csr-ca.py.erb"
  owner node['glassfish']['user']
  mode 0750
  action :create
end

if node['hopsworks']['dela']['enabled'] == "true"
  if node['hopssite']['manual_register'].empty? || node['hopssite']['manual_register'] == "false"
    hopsworks_certs "sign-ca-with-root-hopssite-ca" do
      action :sign_hopssite
    end
  end
end


flyway_tgz = File.basename(node['hopsworks']['flyway_url'])
flyway =  "flyway-" + node['hopsworks']['flyway']['version']

remote_file "#{Chef::Config['file_cache_path']}/#{flyway_tgz}" do
  user node['glassfish']['user']
  group node['glassfish']['group']
  source node['hopsworks']['flyway_url']
  mode 0755
  action :create
end

bash "unpack_flyway" do
  user "root"
  code <<-EOF
    set -e
    cd #{Chef::Config['file_cache_path']}
    tar -xzf #{flyway_tgz}
    mv #{flyway} #{theDomain}
    cd #{theDomain}
    chown -R #{node['glassfish']['user']} flyway*
    rm -rf flyway
    ln -s #{flyway} flyway
  EOF
  not_if { ::File.exists?("#{theDomain}/flyway/flyway") }
end

template "#{theDomain}/flyway/conf/flyway.conf" do
  source "flyway.conf.erb"
  owner node['glassfish']['user']
  mode 0750
  variables({
              :mysql_host => my_ip
            })
  action :create
end

template "#{theDomain}/flyway/flyway-undo.sh" do
  source "flyway-undo.sh.erb"
  owner node['glassfish']['user']
  mode 0750
  action :create
end


directory "#{theDomain}/flyway/undo" do
  owner node['glassfish']['user']
  mode "770"
  action :create
end

template "#{theDomain}/flyway/sql/V0.0.2__initial_tables.sql" do
  source "sql/0.0.2__initial_tables.sql.erb"
  owner node['glassfish']['user']
  mode 0750
  action :create_if_missing
end


template "#{theDomain}/bin/anaconda-command-ssh.sh" do
  source "anaconda-command-ssh.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  mode 0750
  action :create
end

template "#{theDomain}/bin/conda-command-ssh.sh" do
  source "conda-command-ssh.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  mode 0750
  action :create
end
