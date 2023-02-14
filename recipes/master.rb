#rows_path = "#{domains_dir}/post.sql"

case node['platform']
when "rhel"
  package "openssh-clients"
end

package "openssh-server"
public_ip=my_public_ip()
payara_config = "hopsworks-config"
deployment_group = "hopsworks-dg"
master_instance = "master-instance"

domain_name= node['hopsworks']['domain_name']
domains_dir = node['glassfish']['domains_dir']
admin_port = 4848
username=node['hopsworks']['admin']['user']
password=node['hopsworks']['admin']['password']
glassfish_nodes=node['hopsworks']['nodes']
current_version = node['hopsworks']['current_version']

asadmin = "#{node['glassfish']['base_dir']}/versions/current/bin/asadmin"
admin_pwd = "#{domains_dir}/#{domain_name}_admin_passwd"
password_file = "#{domains_dir}/#{domain_name}_admin_passwd"
nodedir= "#{node['glassfish']['install_dir']}/glassfish/versions/current/glassfish"

homedir = conda_helpers.get_user_home(node['hopsworks']['user'])
node.override['glassfish']['install_dir'] = "#{node['glassfish']['install_dir']}/glassfish/versions/current"

package "expect" do
  retries 10
  retry_delay 30
end

if node['hopsworks']['ha']['loadbalancer'].to_s == "true"
  # Install load balancer
  case node['platform_family']
  when "debian"
    package "apache2" do
      retries 10
      retry_delay 30
    end
    template "/etc/apache2/sites-available/loadbalancer.conf"  do
      source 'loadbalancer.conf.erb'
      user 'root'
      action :create
      variables({
        :load_balancer_log_dir => "/var/log/apache2",
        :public_ip => public_ip,
        :glassfish_nodes => glassfish_nodes
      })
    end

    bash "configure load balancer" do
      user 'root'
      code <<-EOF
        sed -i 's/Listen 80$/Listen 1080/' /etc/apache2/ports.conf 
        a2ensite loadbalancer.conf
        a2dissite 000-default.conf
        systemctl restart apache2
      EOF
    end
  when "rhel"
    package ["httpd", "mod_ssl"] do
      retries 10
      retry_delay 30
    end
    directory "/etc/httpd/sites-available" do
      user 'root'
      action :create
      not_if { ::File.directory?('/etc/httpd/sites-available') }
    end
    directory "/etc/httpd/sites-enabled" do
      user 'root'
      action :create
      not_if { ::File.directory?('/etc/httpd/sites-enabled') }
    end

    template "/etc/httpd/sites-available/loadbalancer.conf"  do
      source 'loadbalancer.conf.erb'
      user 'root'
      action :create
      variables({
        :load_balancer_log_dir => "/var/log/httpd",
        :public_ip => public_ip,
        :glassfish_nodes => glassfish_nodes
      })
    end

    bash "configure load balancer" do
      user 'root'
      code <<-EOF
        sed -i 's/Listen 80$/Listen 1080/' /etc/httpd/conf/httpd.conf
        echo 'IncludeOptional sites-enabled/*.conf' >> /etc/httpd/conf/httpd.conf
        ln -s /etc/httpd/sites-available/loadbalancer.conf /etc/httpd/sites-enabled/loadbalancer.conf
        systemctl restart httpd
      EOF
      not_if { ::File.exist?('/etc/httpd/sites-enabled/loadbalancer.conf') }
    end
  end
end

# Create a configuration b/c server-config can not be used for HA
glassfish_asadmin "copy-config default-config #{payara_config}" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
  not_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd} list-configs | grep #{payara_config}"
end

glassfish_asadmin "delete-jvm-options --target #{payara_config} -Xmx512m" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
  only_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd} list-jvm-options --target #{payara_config} | grep Xmx512m"
end

glassfish_asadmin "create-jvm-options --target #{payara_config} -Xss1500k" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
  not_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd} list-jvm-options --target #{payara_config} | grep Xss1500k"
end

glassfish_asadmin "create-jvm-options --target #{payara_config} -Xmx4000m" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
  not_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd} list-jvm-options --target #{payara_config} | grep Xmx4000m"
end

hopsworks_configure_server "glassfish_configure_realm" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  target "#{payara_config}"
  asadmin asadmin
  admin_pwd admin_pwd
  action :glassfish_configure_realm
end

hopsworks_configure_server "glassfish_configure_network" do
  domain_name domain_name
  domains_dir domains_dir
  password_file password_file
  username username
  admin_port admin_port
  target "#{payara_config}"
  asadmin asadmin
  admin_pwd admin_pwd
  internal_port node['hopsworks']['internal']['port']
  action :glassfish_configure_network
end

# temp https-internal.security-enabled=false until proxy ssl is fixed
# disable server monitoring
glassfish_network_listener_conf = {
  "configs.config.#{payara_config}.network-config.network-listeners.network-listener.http-listener-1.enabled" => false,
  "configs.config.#{payara_config}.network-config.network-listeners.network-listener.http-listener-2.enabled" => false,
  "configs.config.#{payara_config}.network-config.network-listeners.network-listener.http-listener-2.port" => '${HTTP_SSL_LISTENER_PORT}',
  "configs.config.#{payara_config}.network-config.protocols.protocol.https-internal.security-enabled" => false,
  "configs.config.server-config.network-config.network-listeners.network-listener.http-listener-2.enabled" => false,
  "configs.config.server-config.network-config.network-listeners.network-listener.https-int-list.enabled" => false,
  "configs.config.server-config.rest-monitoring-configuration.enabled" => false,
  "configs.config.server-config.monitoring-service.mbean-enabled" => false,
  "configs.config.server-config.monitoring-service.monitoring-enabled" => false,
  "configs.config.server-config.microprofile-metrics-configuration.enabled" => false
}

hopsworks_configure_server "glassfish_configure" do
  domain_name domain_name
  domains_dir domains_dir
  password_file password_file
  username username
  admin_port admin_port
  target "#{payara_config}"
  asadmin asadmin
  admin_pwd admin_pwd
  override_props glassfish_network_listener_conf
  action :glassfish_configure
end

hopsworks_configure_server "glassfish_configure_monitoring" do
  domain_name domain_name
  domains_dir domains_dir
  password_file password_file
  username username
  admin_port admin_port
  target "#{payara_config}"
  asadmin asadmin
  admin_pwd admin_pwd
  action :glassfish_configure_monitoring
end

glassfish_asadmin "set-hazelcast-configuration --publicaddress #{public_ip}" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
end

glassfish_asadmin "set-hazelcast-configuration --daspublicaddress #{public_ip}" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
end

# --nodedir #{domains_dir}/nodes will fail to start and need restarting from the node
# start-local-instance --node localhost-domain1 --nodedir #{domains_dir}/nodes --sync normal --timeout 120 master-instance
glassfish_asadmin "create-local-instance --config #{payara_config} --nodedir #{nodedir}/nodes #{master_instance}" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
  not_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd} list-instances | grep #{master_instance}"
end

#
# mod_ajp http://www.devwithimagination.com/2015/08/13/apache-as-a-reverse-proxy-to-glassfish/
#
# https://dzone.com/articles/configure-a-glassfish-cluster-with-automatic-load
# docker
# https://github.com/jelastic-jps/glassfish/
# --nodedir #{domains_dir}/nodes will fail to start and need restarting from the node
glassfish_nodes.each_with_index do |val, index|
  glassfish_asadmin "create-node-ssh --nodehost #{val} --installdir #{node['glassfish']['base_dir']}/versions/current --nodedir #{nodedir}/nodes worker#{index}" do
    domain_name domain_name
    password_file password_file
    username username
    admin_port admin_port
    secure false
    not_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd} list-nodes | grep worker#{index}"
  end
  glassfish_asadmin "create-instance --config #{payara_config} --node worker#{index} instance#{index}" do
    domain_name domain_name
    password_file password_file
    username username
    admin_port admin_port
    secure false
    not_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd} list-instances | grep instance#{index}"
  end
end

glassfish_asadmin "create-deployment-group #{deployment_group}" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
  not_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd} list-deployment-groups | grep #{deployment_group}"
end

glassfish_asadmin "add-instance-to-deployment-group --instance #{master_instance} --deploymentgroup #{deployment_group}" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
end

glassfish_nodes.each_with_index do |val, index|
  glassfish_asadmin "add-instance-to-deployment-group --instance instance#{index} --deploymentgroup #{deployment_group}" do
    domain_name domain_name
    password_file password_file
    username username
    admin_port admin_port
    secure false
  end
end

# Resources created in default server, so create a reference to the resources in the new config
glassfish_resources = [
  'concurrent/hopsThreadFactory',
  'concurrent/condaExecutorService',
  'concurrent/hopsExecutorService',
  'concurrent/jupyterExecutorService',
  'concurrent/condaScheduledExecutorService',
  'concurrent/hopsScheduledExecutorService',
  'concurrent/kagentExecutorService',
  'jdbc/airflow', 
  'jdbc/featurestore', 
  'jdbc/hopsworks', 
  'jdbc/hopsworksTimers',
  'ldap/LdapResource',
  'mail/BBCMail']

glassfish_resources.each do |val|
  glassfish_asadmin "create-resource-ref --target #{deployment_group} #{val}" do
    domain_name domain_name
    password_file password_file
    username username
    admin_port admin_port
    secure false
    only_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd} list-resource-refs server | grep #{val}"
    not_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd} list-resource-refs #{deployment_group} | grep #{val}"
  end
end

glassfish_deployable "hopsworks-ear" do
  component_name "hopsworks-ear:#{node['hopsworks']['version']}"
  target "server"
  version current_version
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  action :undeploy
  retries 1
  keep_state true
  enabled true
  secure true
  ignore_failure true
  only_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd}  list-applications --type ejb server | grep -w \"hopsworks-ear:#{node['hopsworks']['version']}\""
end

glassfish_deployable "hopsworks" do
  component_name "hopsworks-web:#{node['hopsworks']['version']}"
  target "server"
  version current_version
  context_root "/hopsworks"
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure true
  action :undeploy
  async_replication false
  retries 1
  keep_state true
  enabled true
  ignore_failure true 
  only_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd}  list-applications --type web server | grep -w \"hopsworks-web:#{node['hopsworks']['version']}\"" 
end

glassfish_deployable "hopsworks-ca" do
  component_name "hopsworks-ca:#{node['hopsworks']['version']}"
  target "server"
  version current_version
  context_root "/hopsworks-ca"
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure true
  action :undeploy
  async_replication false
  retries 1
  keep_state true
  enabled true
  ignore_failure true
  only_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd}  list-applications --type ejb server | grep -w \"hopsworks-ca:#{node['hopsworks']['version']}\""
end

# Check the version of the deployed and redeploy if different
# Check if <nodes-dir>/nodes/localhost-domain1/master-instance/docroot/ exists before creating local-instance and node-ssh
# and redeploy frontend if it exists.

#restart only if new
glassfish_asadmin "restart-domain" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
  only_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd} list-instances #{deployment_group} | grep -w \"not running\""
end

hopsworks_configure_server "change_node_master_password" do
  username username
  asadmin asadmin
  admin_pwd admin_pwd
  nodedir nodedir
  node_name "localhost-domain1"
  current_master_password "changeit"
  action :change_node_master_password
end

#proper way is to run change_node_master_password on each node 
glassfish_nodes.each_with_index do |val, index|
  bash "copy master password" do
    user "#{node['glassfish']['user']}"
    code <<-EOF
      scp #{nodedir}/nodes/localhost-domain1/agent/master-password #{val}:#{nodedir}/nodes/worker#{index}/agent/
    EOF
  end
end

glassfish_asadmin "start-deployment-group --instancetimeout 620 #{deployment_group}" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
  only_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd} list-instances #{deployment_group} | grep -w \"not running\""
end

if current_version.eql?("") == false
  #
  # undeploy previous version
  #
  glassfish_deployable "hopsworks-ear" do
    component_name "hopsworks-ear:#{node['hopsworks']['current_version']}"
    target deployment_group
    version current_version
    domain_name domain_name
    password_file "#{domains_dir}/#{domain_name}_admin_passwd"
    username username
    admin_port admin_port
    action :undeploy
    retries 1
    keep_state true
    enabled true
    secure true
    ignore_failure true
  end

  glassfish_deployable "hopsworks" do
    component_name "hopsworks-web:#{node['hopsworks']['current_version']}"
    target deployment_group
    version current_version
    context_root "/hopsworks"
    domain_name domain_name
    password_file "#{domains_dir}/#{domain_name}_admin_passwd"
    username username
    admin_port admin_port
    secure true
    action :undeploy
    async_replication false
    retries 1
    keep_state true
    enabled true
    ignore_failure true  
  end

  glassfish_deployable "hopsworks-ca" do
    component_name "hopsworks-ca:#{node['hopsworks']['current_version']}"
    target deployment_group
    version current_version
    context_root "/hopsworks-ca"
    domain_name domain_name
    password_file "#{domains_dir}/#{domain_name}_admin_passwd"
    username username
    admin_port admin_port
    secure true
    action :undeploy
    async_replication false
    retries 1
    keep_state true
    enabled true
    ignore_failure true
  end
end    

# change reference of the deployed apps will require restarting instances
glassfish_deployable "hopsworks-ca" do
  component_name "hopsworks-ca:#{node['hopsworks']['version']}"
  target deployment_group
  url node['hopsworks']['ca_url']
  auth_username node['install']['enterprise']['username']
  auth_password node['install']['enterprise']['password']
  version node['hopsworks']['version']
  context_root "/hopsworks-ca"
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
  action :deploy
  async_replication false
  retries 1
  keep_state true
  enabled true
  not_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd}  list-applications --type ejb #{deployment_group} | grep -w \"hopsworks-ca:#{node['hopsworks']['version']}\""
end

glassfish_deployable "hopsworks-ear" do
  component_name "hopsworks-ear:#{node['hopsworks']['version']}"
  target deployment_group
  url node['hopsworks']['ear_url']
  auth_username node['install']['enterprise']['username']
  auth_password node['install']['enterprise']['password']
  version node['hopsworks']['version']
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
  action :deploy
  async_replication false
  retries 1
  keep_state true
  enabled true
  not_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd}  list-applications --type ejb #{deployment_group} | grep -w \"hopsworks-ear:#{node['hopsworks']['version']}\""
end

glassfish_deployable "hopsworks" do
  component_name "hopsworks-web:#{node['hopsworks']['version']}"
  target deployment_group
  url node['hopsworks']['war_url']
  auth_username node['install']['enterprise']['username']
  auth_password node['install']['enterprise']['password']
  version node['hopsworks']['version']
  context_root "/hopsworks"
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
  action :deploy
  async_replication false
  retries 1
  keep_state true
  enabled true
  not_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd}  list-applications --type web #{deployment_group} | grep -w \"hopsworks-web:#{node['hopsworks']['version']}\""
end