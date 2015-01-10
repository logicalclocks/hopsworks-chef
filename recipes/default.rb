##############################################################################
# Create databases to be used by web application and hop and populate them.
###############################################################################

# Links for reading:
# http://computingat40s.wordpress.com/how-to-create-a-custom-realm-in-glassfish-3-1-2-2/



# Check if it is an AWS or Openstack - if yes, store the AWS/Openstack credentials
#if "#{node[:hopshub][:public_key]}".empty? == false && "#{node[:provider][:name]}".empty? == false && "#{node[:provider][:access_key]}".empty? == false && "#{node[:provider][:account_id]}".empty? == false

private_ip=my_private_ip()

hopshub_grants "create_kthfs_db"  do
  action :create_db
end 

kthfs_path = "#{Chef::Config[:file_cache_path]}/kthfs.sql"

hopshub_grants "kthfs"  do
  kthfs_path  "#{kthfs_path}"
  action :nothing
end 

begin
  t = resources("template[#{kthfs_path}]")
rescue
  Chef::Log.info("Could not find previously defined #{kthfs_path} resource")
  t = template kthfs_path do
    source File.basename("#{kthfs_path}") + ".erb"
    owner "root" 
    mode "0600"
    action :create
    variables({
                :private_ip => private_ip
              })
    notifies :populate_db, "hopshub_grants[kthfs]", :immediately
  end 
end



# template "#{Chef::Config[:file_cache_path]}/graphs.sql" do
#   source "graphs.sql.erb"
#   owner node[:glassfish][:user]
#   group node[:glassfish][:group]
#   mode 0755
#   action :create
# end


# graphs_path = "#{Chef::Config[:file_cache_path]}/graphs.sql"

# hopshub_grants "graphs"  do
#   graphs_path  "#{graphs_path}"
#   action :nothing
# end 

# begin
#   t = resources("template[#{graphs_path}]")
# rescue
#   Chef::Log.info("Could not find previously defined #{graphs_path} resource")
#   t = template graphs_path do
#     source File.basename("#{graphs_path}") + ".erb"
#     owner node[:glassfish][:user]
#     group node[:glassfish][:group]
#     mode "0660"
#     action :create
#     notifies :graphs, "hopshub_grants[graphs]", :immediately
#   end
# end



###############################################################################
# config glassfish
###############################################################################

Chef::Log.info "Admin user: #{node.default[:hopshub][:admin][:user]}"

domain_name="domain1"
admin_port=node[:glassfish][:admin][:port] 
port=node[:glassfish][:port]
secure=true
username="#{node[:hopshub][:admin][:user]}"
password="#{node[:hopshub][:admin][:password]}"
master_password="#{node[:glassfish][:cert][:password]}"
password_file="#{node[:glassfish]['domains_dir']}/#{domain_name}_admin_passwd"
config_dir="#{node[:glassfish][:domains_dir]}/#{domain_name}/config"
asadmin="#{node[:glassfish][:base_dir]}/glassfish/bin/asadmin"

glassfish_domain "#{domain_name}" do
  username username
  password password
  password_file username ? "#{node[:glassfish]['domains_dir']}/#{domain_name}_admin_passwd" : nil
  port port 
  admin_port admin_port
  secure secure 
  echo true
  terse false
  min_memory node[:glassfish][:min_mem]
  max_memory node[:glassfish][:max_mem]
  max_stack_size node[:glassfish][:max_stack_size]
  max_perm_size node[:glassfish][:max_perm_size]
  action :create
end


keytool_path="#{node[:java][:java_home]}/bin"

if node[:java][:java_home].to_s == ''
 if ENV['JAVA_HOME'].to_s != ''
   keytool_path="#{ENV['JAVA_HOME']}/bin"
 else
   keytool_path="/usr/bin"
 end
end

bash "delete_invalid_certs" do
  user node[:glassfish][:user]
  group node[:glassfish][:group]
   code <<-EOF
# This cert has expired, blocks startup of glassfish
   {keytool_path}/keytool -delete -alias gtecybertrust5ca -keystore #{config_dir}/cacerts.jks -storepass #{master_password}
   {keytool_path}/keytool -delete -alias gtecybertrustglobalca -keystore #{config_dir}/cacerts.jks -storepass #{master_password}
   EOF
   only_if "#{node[:java][:java_home]}/bin/keytool -keystore #{config_dir}/cacerts.jks -storepass #{master_password} -list | grep -i gtecybertrustglobalca"
end

bash "create_glassfish_certs" do
  user node[:glassfish][:user]
  group node[:glassfish][:group]
   code <<-EOF

   #{keytool_path}/keytool -delete -alias s1as -keystore #{config_dir}/keystore.jks -storepass #{master_password}
   #{keytool_path}/keytool -delete -alias glassfish-instance -keystore #{config_dir}/keystore.jks -storepass #{master_password}

 # Generate two new certs with same alias as original certs
   #{keytool_path}/keytool -keysize 2048 -genkey -alias s1as -keyalg RSA -dname "CN=#{node[:caramel][:cert][:cn]},O=#{node[:caramel][:cert][:o]},OU=#{node[:caramel][:cert][:ou]},L=#{node[:caramel][:cert][:l]},S=#{node[:caramel][:cert][:s]},C=#{node[:caramel][:cert][:c]}" -validity 3650 -keypass #{node[:hopshub][:cert][:password]} -storepass #{master_password} -keystore #{config_dir}/keystore.jks
   #{keytool_path}/keytool -keysize 2048 -genkey -alias glassfish-instance -keyalg RSA -dname "CN=#{node[:caramel][:cert][:cn]},O=#{node[:caramel][:cert][:o]},OU=#{node[:caramel][:cert][:ou]},L=#{node[:caramel][:cert][:l]},S=#{node[:caramel][:cert][:s]},C=#{node[:caramel][:cert][:c]}" -validity 3650 -keypass #{node[:hopshub][:cert][:password]} -storepass #{master_password} -keystore #{config_dir}/keystore.jks

   #Add two new certs to cacerts.jks
   #{keytool_path}/keytool -export -alias glassfish-instance -file glassfish-instance.cert -keystore #{config_dir}/keystore.jks -storepass #{master_password}
   #{keytool_path}/keytool -export -alias s1as -file #{config_dir}/s1as.cert -keystore #{config_dir}/keystore.jks -storepass #{master_password}
  
   #{keytool_path}/keytool -import -noprompt -alias s1as -file #{config_dir}/s1as.cert -keystore #{config_dir}/cacerts.jks -storepass #{master_password}
   #{keytool_path}/keytool -import -noprompt -alias glassfish-instance -file #{config_dir}/glassfish-instance.cert -keystore #{config_dir}/cacerts.jks -storepass #{master_password}
  
   touch #{node[:glassfish][:base_dir]}/.certs_generated
   EOF
   not_if "test -f #{node[:glassfish][:base_dir]}/.certs_generated"
end

admin_pwd="#{node[:glassfish][:domains_dir]}/#{domain_name}_admin_passwd"

file "#{admin_pwd}" do
   action :delete
end

template "#{admin_pwd}" do
  cookbook 'hopshub'
  source "password.erb"
  owner node[:glassfish][:user]
  group node[:glassfish][:group]
  mode "0600"
  variables(:password => password, :master_password => master_password)
end

glassfish_secure_admin domain_name do
  domain_name domain_name
  password_file password_file 
  username username
  admin_port admin_port
  secure false
  action :enable
end

bash "stop_#{domain_name}_after_enable_security" do
  user "root"
  code <<-EOF
    initctl stop glassfish-#{domain_name} || true
 EOF
end


if platform_family?("debian")
   hopshub_upstart "domain1" do
     admin_pwd "#{admin_pwd}"
     username "#{username}"
     action :generate
   end

   bash "start_#{domain_name}_after_enable_security" do
    user "root"
    code <<-EOF
    sleep 5
    initctl start glassfish-#{domain_name} || true
   EOF
   end

else

  # Need to restart to apply new secure SSL connection when connecting to admin console
  bash "restart_#{domain_name}_after_enable_security" do
    user "root"
    code <<-EOF
    initctl stop glassfish-#{domain_name} || true
#    ps -ef | grep glassfish | grep -v grep | awk '{print $2}' | xargs kill -9 || true
    sleep 5
    initctl start glassfish-#{domain_name} 
    EOF
  end

end

mysql_tgz = File.basename(node[:glassfish]['mysql_connector'])
mysql_base = File.basename(node[:glassfish]['mysql_connector'], ".tar.gz") 

path_mysql_tgz = "#{Chef::Config[:file_cache_path]}/#{mysql_tgz}"

remote_file path_mysql_tgz do
  user "root"
  source node[:glassfish]['mysql_connector']
  mode 0755
  action :create_if_missing
end


bash "unpack_mysql_connector" do
    user "root"
    code <<-EOF
   tar -xzf #{path_mysql_tgz} -C #{Chef::Config[:file_cache_path]}
   # copy mysql-connector jar file to lib/ dir of domain1.
   cp #{Chef::Config[:file_cache_path]}/#{mysql_base}/#{mysql_base}-bin.jar #{node[:glassfish]['domains_dir']}/#{domain_name}/lib
   touch #{Chef::Config[:file_cache_path]}/.mysqlconnector_downloaded
EOF
  not_if { ::File.exists?( "#{Chef::Config[:file_cache_path]}/.mysqlconnector_downloaded")}
end
kthfs_db = "kthfs"

mysql_user=node[:mysql][:user]
mysql_pwd=node[:mysql][:password]

if node[:ndb][:mysqld][:private_ips].length == 1
#  mysql_ips = node[:ndb][:mysqld][:private_ips].at(0) + "\\:" + node[:ndb][:mysql_port].to_s
  mysql_ips = private_recipe_ip("ndb","mysqld")
else
  mysql_ips = node[:ndb][:mysqld][:private_ips].join("\\:" + node[:ndb][:mysql_port].to_s + ",")
  mysql_ips.chop
end

Chef::Log.info "JDBC Connection: #{mysql_ips}"

# glassfish_jdbc_connection_pool "#{domain_name}-jdbc-connection-pool" do
#   username username
#   password_file "#{node[:glassfish]['domains_dir']}/#{domain_name}_admin_passwd"
#   admin_port admin_port
#   secure secure 
#   echo true
#   terse false
#   datasourceclassname "com.mysql.jdbc.jdbc2.optional.MysqlConnectionPoolDataSource"
#   driverclassname ""
#   restype "javax.sql.DataSource"
#   nontransactionalconnections false
#   creationretryattempts 1
#   creationretryinterval 2
#   validationmethod "auto-commit"
#   isconnectvalidatereq true
#   isolationlevel "read-committed"
#   action :create
# end

# package "expect" do
# end                                                                                                                                                                            

# bash "change_master_passwd" do
#    user node[:glassfish][:user]
#    group node[:glassfish][:group]
#    code <<-EOF
#     initctl stop glassfish-#{domain_name}
#     expect -c 'spawn #{asadmin} change-master-password --savemasterpassword=true
#     expect "Please enter the new master password> "
#     send "#{node[:caramel][:master][:password]}\r"
#     expect "Please enter the new master password again> "
#     send "#{node[:caramel][:master][:password]}\r"
#     expect eof'
#   EOF
#   not_if { ::File.exists?( "#{password_file}")}
# end

#--nontransactionalconnections=true 
# command_string = []
# command_string << "#{asadmin} --user #{username} --passwordfile #{admin_pwd} create-jdbc-connection-pool  --datasourceclassname com.mysql.jdbc.jdbc2.optional.MysqlConnectionPoolDataSource --restype javax.sql.DataSource --creationretryattempts=1 --creationretryinterval=2 --validationmethod=auto-commit --isconnectvalidatereq=true --isolationlevel=read-committed --property ServerName=#{mysql_ips}:User=#{mysql_user}:Password=#{mysql_pwd}:DatabaseName=#{kthfs_db}\" #{kthfs_db}"
# command_string << "#{asadmin} --user #{username} --passwordfile #{admin_pwd} create-jdbc-resource --connectionpoolid #{kthfs_db} --enabled=true jdbc/#{kthfs_db}"
# command_string << "touch #{node[:glassfish][:domains_dir]}/#{domain_name}/.#{kthfs_db}_jdbc_installed"
#Chef::Log.info(command_string.join("\t"))

bash "install_jdbc" do
   user node[:glassfish][:user]
   group node[:glassfish][:group]
#   code command_string.join("\n")
# --isolationlevel=read-committed 
 code <<-EOF
#{asadmin} --user #{username} --passwordfile #{admin_pwd} create-jdbc-connection-pool  --datasourceclassname com.mysql.jdbc.jdbc2.optional.MysqlConnectionPoolDataSource --restype javax.sql.DataSource --creationretryattempts=1 --creationretryinterval=2 --validationmethod=auto-commit --isconnectvalidatereq=true --property "ServerName=#{mysql_ips}:Port=#{node[:ndb][:mysql_port]}:User=#{mysql_user}:Password=#{mysql_pwd}:DatabaseName=#{kthfs_db}" #{kthfs_db}
#{asadmin} --user #{username} --passwordfile #{admin_pwd} create-jdbc-resource --connectionpoolid #{kthfs_db} --enabled=true jdbc/#{kthfs_db}
touch #{node[:glassfish][:domains_dir]}/#{domain_name}/.#{kthfs_db}_jdbc_installed
EOF
  not_if { ::File.exists?( "#{node[:glassfish][:domains_dir]}/#{domain_name}/.#{kthfs_db}_jdbc_installed") }
# not_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd} list-jdbc-resources | grep -i #{kthfs_db}"
 end

command_string = []
command_string << "#{asadmin} --user #{username} --passwordfile #{admin_pwd}  create-auth-realm --classname com.sun.enterprise.security.auth.realm.jdbc.JDBCRealm --property \"jaas-context=jdbcRealm:datasource-jndi=jdbc/#{kthfs_db}:group-table=USERS_GROUPS:user-table=USERS:group-name-column=GROUPNAME:digest-algorithm=none:user-name-column=EMAIL:encoding=Hex:password-column=PASSWORD:assign-groups=ADMIN,USER,AGENT:group-table-user-name-column=EMAIL:digestrealm-password-enc-algorithm= :db-user=#{mysql_user}:db-password=#{mysql_pwd}\" DBRealm"
command_string << "#{asadmin} --user #{username} --passwordfile #{admin_pwd}  set server-config.security-service.default-realm=DBRealm"
command_string << "#{asadmin} --user #{username} --passwordfile #{admin_pwd}  set domain.resources.jdbc-connection-pool.#{kthfs_db}.is-connection-validation-required=true"
command_string << "#{asadmin} --user #{username} --passwordfile #{admin_pwd} set server-config.network-config.protocols.protocol.admin-listener.security-enabled=true"
command_string << "#{asadmin} --user #{username} --passwordfile #{admin_pwd} enable-secure-admin"
command_string << "# #{asadmin} --user #{username} --passwordfile #{admin_pwd}  set-log-level javax.enterprise.system.core.security=FINEST"
# email resources https://docs.oracle.com/cd/E18930_01/html/821-2416/giowr.html
# --port #{node[:hopshub][:smtp][:port]} 
#command_string << "#{asadmin} --user #{username} --passwordfile #{admin_pwd} create-javamail-resource --mailhost #{node[:hopshub][:smtp][:server]} --mailuser #{node[:hopshub][:smtp][:username]}  --fromaddress #{node[:hopshub][:smtp][:username]} --transprotocol smtp --enabled=true --secure false --property mail-smtp.user=hadoop@hops.io:mail-smtp.port=25:mail-smtp.password=fake:mail-smtp.auth=false mail/BBCMail"
# #{node[:hopshub][:smtp][:secure]} jndi/mail"

#asadmin --interactive=false create-javamail-resource --mailhost=smtp.gmail.com --mailuser=cejug.classifieds --fromaddress=cejug.classifieds@gmail.com --enabled=true --description="e-Mail account used to confirm the registration of the Cejug-Classifieds users" --storeprotocol=imap --storeprotocolclass=com.sun.mail.imap.IMAPStore --transprotocol smtp --transprotocolclass com.sun.mail.smtp.SMTPSSLTransport --property mail-smtp.user=cejug.classifieds@gmail.com:mail-smtp.port=465:mail-smtp.password=fake:mail-smtp.auth=true:mail-smtp.socketFactory.fallback=false:mail-smtp.socketFactory.class=javax.net.ssl.SSLSocketFactory:mail-smtp.socketFactory.port=465:mail-smtp.starttls.enable=true mail/classifieds

Chef::Log.info(command_string.join("\t"))
# See http://docs.oracle.com/cd/E26576_01/doc.312/e24938/create-auth-realm.htm
 bash "jdbc_auth_realm" do
   user node[:glassfish][:user]
   group node[:glassfish][:group]
   code command_string.join("\n")
   not_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd} list-auth-realms | grep -i DBRealm"
 end


kthfsmgr_url = node['kthfs']['mgr']
kthfsmgr_filename = File.basename(kthfsmgr_url)
cached_kthfsmgr_filename = "#{Chef::Config[:file_cache_path]}/#{kthfsmgr_filename}"

Chef::Log.info "Downloading #{cached_kthfsmgr_filename} from #{kthfsmgr_url} "

remote_file cached_kthfsmgr_filename do
    source kthfsmgr_url
    mode 0755
    owner node[:glassfish][:user]
    group node[:glassfish][:group]
    action :create_if_missing
end


bash "set_long_timeouts_for_ssh_ops" do
  user node[:glassfish][:user]
  group node[:glassfish][:group]
 code <<-EOF
   cd #{node[:glassfish][:base_dir]}/glassfish/bin   
   #{asadmin} --user #{username} --passwordfile #{admin_pwd}  set server-config.network-config.protocols.protocol.http-listener-1.http.request-timeout-seconds=7200
   #{asadmin} --user #{username} --passwordfile #{admin_pwd}  set server-config.network-config.protocols.protocol.http-listener-2.http.request-timeout-seconds=7200
 EOF
end


Chef::Log.info "Installing HopsHub "
command_string = []
#  --verify=true
command_string << "#{asadmin} --user #{username} --passwordfile #{admin_pwd} deploy --createtables=true --enabled=true --upload=true --availabilityenabled=true --force=true --name HopsHub #{cached_kthfsmgr_filename}"
Chef::Log.info(command_string.join("\t"))
bash "installing_dashboard" do
  user node[:glassfish][:user]
  group node[:glassfish][:group]
   code command_string.join("\n")
  not_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd}  list-applications --type ejb | grep -w 'HopsHub'"
end


# http://www.nabisoft.com/tutorials/glassfish/installing-glassfish-311-on-ubuntu
bash "disable_poweredby" do
   user "root"
   code <<-EOF
   cd #{node[:glassfish][:base_dir]}/glassfish/bin   
   #disable sending x-powered-by in http header (Glassfish obfuscation)
   #{asadmin} --user #{username} --passwordfile #{admin_pwd}  set server.network-config.protocols.protocol.http-listener-1.http.xpowered-by=false 
   #{asadmin} --user #{username} --passwordfile #{admin_pwd}  set server.network-config.protocols.protocol.http-listener-2.http.xpowered-by=false
   #{asadmin} --user #{username} --passwordfile #{admin_pwd}  set server.network-config.protocols.protocol.admin-listener.http.xpowered-by=false
  
   #get rid of http header field value "server" (Glassfish obfuscation)
   # skip if failed: || true
   #{asadmin} --user #{username} --passwordfile #{admin_pwd}  create-jvm-options -Dproduct.name="" || true
   chown #{node[:glassfish][:user]} /usr/local
   touch #{node[:glassfish][:base_dir]}/.poweredby_disabled
   EOF
  not_if { ::File.exist?("#{node[:glassfish][:base_dir]}/.poweredby_disabled") }
end


if "#{node[:ndb][:enabled]}" == "true"
   alter_table_path = "#{Chef::Config[:file_cache_path]}/alter-table-ndb.sql"

  hopshub_restart "switchToNdb" do
    alter_path alter_table_path
  end

   begin
     t = resources("template[#{alter_table_path}]")
   rescue
     Chef::Log.info("Could not find previously defined #{alter_table_path} resource")
     t = template alter_table_path do
       source File.basename("#{alter_table_path}") + ".erb"
       owner "root"
       group node['mysql']['root_group']
       mode "0600"
       action :create
#       notifies :alter_tables, "hopshub_restart[switchToNdb]", :immediately
     end 
   end
end


if node[:kagent][:enabled] == "true"
 kagent_kagent "restart_agent_to_register" do
   action :restart
 end
end
