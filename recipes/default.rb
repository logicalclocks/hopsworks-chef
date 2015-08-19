require 'json'


bash 'fix_java_path_for_glassfish_cookbook' do
user "root"
    code <<-EOF
# upstart job in glassfish expects java to be installed in /bin/java
test -f /usr/bin/java && ln -sf /usr/bin/java /bin/java 
EOF
end


private_ip=my_private_ip()
hopsworks_db = "hopsworks"
realm="kthfsRealm"
mysql_user=node[:mysql][:user]
mysql_pwd=node[:mysql][:password]


# hopsworks_grants "create_hopsworks_db"  do
#   action :create_db
# end 

tables_path = "#{Chef::Config[:file_cache_path]}/tables.sql"
rows_path = "#{Chef::Config[:file_cache_path]}/rows.sql"


hopsworks_grants "creds" do
  tables_path  "#{tables_path}"
  rows_path  "#{rows_path}"
  action :nothing
end 

 Chef::Log.info("Could not find previously defined #{tables_path} resource")
 template tables_path do
    source File.basename("#{tables_path}") + ".erb"
    owner node[:glassfish][:user]
    mode 0750
    action :create
    variables({
                :private_ip => private_ip
              })
    notifies :create_tables, 'hopsworks_grants[creds]', :immediately
  end 



template "#{rows_path}" do
   source File.basename("#{rows_path}") + ".erb"
   owner node[:glassfish][:user]
   mode 0755
   action :create
   notifies :insert_rows, 'hopsworks_grants[creds]', :immediately
end



###############################################################################
# config glassfish
###############################################################################



# group node[:glassfish][:group] do
# end

# user node['glassfish']['user'] do
#   supports :manage_home => true
#   home "/home/#{node['glassfish']['user']}"
#   shell '/bin/bash'
#   action :create
#   system true
#   not_if "getent passwd #{node['glassfish']['user']}"
# end

# group node[:glassfish][:group] do
#   action :modify
#   members node[:glassfish][:user] 
#   append true
# end

username="adminuser"
password="adminpw"
domain_name="domain1"
domains_dir = '/usr/local/glassfish/glassfish/domains'
admin_port = 4848
mysql_host = private_recipe_ip("ndb","mysqld")
mysql_user = "kthfs"
mysql_password = "kthfs"


node.override = {
  'java' => {
    'install_flavor' => 'oracle',
    'jdk_version' => 7,
    'oracle' => {
      'accept_oracle_download_terms' => true
    }
  },
  'glassfish' => {
    'version' => '4.1',
    'base_dir' => '/usr/local/glassfish',
    'domains_dir' => domains_dir,
    'domains' => {
      domain_name => {
        'config' => {
          'min_memory' => 1024,
          'max_memory' => 1024,
          'max_perm_size' => 256,
          'port' => 8080,
          'admin_port' => admin_port,
          'username' => username,
          'password' => password,
          'master_password' => 'mykeystorepassword',
          'remote_access' => false,
          'jvm_options' => ['-DMYAPP_CONFIG_DIR=/usr/local/myapp/config', '-Dcom.sun.enterprise.tools.admingui.NO_NETWORK=true'],
          'secure' => false
        },
        'extra_libraries' => {
          'jdbcdriver' => {
            'type' => 'common',
            'url' => 'http://snurran.sics.se/hops/mysql-connector-java-5.1.29-bin.jar'
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
            'maxthreadpoolsize' => 50,
            'minthreadpoolsize' => 5,
            'maxqueuesize' => 256
          }
        },
        'iiop_listeners' => {
          'orb-listener-1' => {
            'enabled' => true,
            'iiopport' => 1072,
            'securityenabled' => false
          }
        },
        'context_services' => {
          'concurrent/MyAppContextService' => {
            'description' => 'My Apps ContextService'
          }
        },
        'managed_thread_factories' => {
          'concurrent/myThreadFactory' => {
            'threadpriority' => 12,
            'description' => 'My Thread Factory'
          }
        },
        'managed_executor_services' => {
          'concurrent/myExecutorService' => {
            'threadpriority' => 12,
            'description' => 'My Executor Service'
          }
        },
        'managed_scheduled_executor_services' => {
          'concurrent/myScheduledExecutorService' => {
            'corepoolsize' => 12,
            'description' => 'My Executor Service'
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
              'description' => 'App Pool',
              'properties' => {
                'Url' => "jdbc:mysql://#{mysql_host}:3306/",
                'User' => mysql_user,
                'Password' => mysql_password
              }
            },
            'resources' => {
              'jdbc/hopsworks' => {
                'description' => 'Resource for App Pool',
              }
            }
          }
        },
        'deployables' => {
          'hopsworks' => {
            'url' => 'http://snurran.sics.se/hops/hopsworks.war',
            'context_root' => '/hopsworks'
          }
        },
      }
    }
  }
}

include_recipe 'glassfish::default'
include_recipe 'glassfish::attribute_driven_domain'

glassfish_secure_admin domain_name do
  domain_name domain_name
  password_file "#{domains_dir}/#{domain_name}_admin_passwd"
  username username
  admin_port admin_port
  secure false
  action :enable
end

# glassfish_deployable "hopsworks" do
#   component_name "hopsworks"
#   url "http://snurran.sics.se/hops/hopsworks.war"
#   context_root "/"
#   domain_name domain_name
#   password_file "#{domains_dir}/#{domain_name}_admin_passwd"
#   username username
#   admin_port admin_port
#   secure false
#   availability_enabled true
#   action :deploy
# end

props =  { 
  'datasource-jndi' => 'jdbc/hopsworks',
  'password-column' => 'password',
  'group-table' => 'users_groups',
  'user-table' => 'users',
  'group-name-column' => 'group_name',
  'user-name-column' => 'email',
  'group-table-user-name-column' => 'email',
  'encoding' => 'hex',
  'digest-algorithm' => 'SHA-256'
}

 glassfish_auth_realm "kthfsRealm" do 
   realm_name "kthfsRealm"
   jaas_context "jdbcrealm"
   properties props
   domain_name domain_name
   password_file "#{domains_dir}/#{domain_name}_admin_passwd"
   username username
   admin_port admin_port
   secure false
   classname "com.sun.enterprise.security.auth.realm.jdbc.JDBCRealm"
 end

# Avoid empty property values - glassfish will crash otherwise
if node[:hopsworks][:gmail][:email].empty?
  node.default[:hopsworks][:gmail][:email]="none"
end

if node[:hopsworks][:gmail][:password].empty?
  node.default[:hopsworks][:gmail][:password]="empty"
end


gmailProps = {
  'mail-smtp-host' => 'smtp.gmail.com',
  'mail-smtp-user' => "#{node[:hopsworks][:gmail][:email]}",
  'mail-smtp-password' => "#{node[:hopsworks][:gmail][:password]}",
  'mail-smtp-auth' => 'true',
  'mail-smtp-port' => '587',
  'mail-smtp-socketFactory-port' => '465',
  'mail-smtp-socketFactory-class' => 'javax.net.ssl.SSLSocketFactory',
  'mail-smtp-starttls-enable' => 'true',
  'mail.smtp.ssl.enable' => 'false',
  'mail-smtp-socketFactory-fallback' => 'false'
}

 glassfish_javamail_resource "gmail" do 
   jndi_name "mail/BBCMail"
   mailuser node[:hopsworks][:gmail][:email]
   mailhost "smtp.gmail.com"
   fromaddress node[:hopsworks][:gmail][:email]
   properties gmailProps
   domain_name domain_name
   password_file "#{domains_dir}/#{domain_name}_admin_passwd"
   username username
   admin_port admin_port
   secure false
   action :create
 end

