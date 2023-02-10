domain_name= node['hopsworks']['domain_name']
domains_dir = node['hopsworks']['domains_dir']
# This is set correctly in hopsworks::install by the chef-glassfish recipe. As each recipe has it's own
# instance of chef we need to re-set it here.
# If you set it in the attributes it will break glassfish installation.
node.override['glassfish']['install_dir'] = "#{node['glassfish']['install_dir']}/glassfish/versions/current"
theDomain="#{domains_dir}/#{domain_name}"

public_ip=my_public_ip()
realmname = "kthfsrealm"
payara_config = "hopsworks-config"

username = node['hopsworks']['admin']['user']
password = node['hopsworks']['admin']['password']
admin_port = node['hopsworks']['admin']['port']

jndiDB = "jdbc/hopsworks"

asadmin = "#{node['glassfish']['base_dir']}/versions/current/bin/asadmin"
admin_pwd = "#{domains_dir}/#{domain_name}_admin_passwd"

password_file = "#{domains_dir}/#{domain_name}_admin_passwd"

props =  {
  'datasource-jndi' => jndiDB,
  'password-column' => 'password',
  'group-table' => 'hopsworks.users_groups',
  'user-table' => 'hopsworks.users',
  'group-name-column' => 'group_name',
  'user-name-column' => 'email',
  'group-table-user-name-column' => 'email',
  'encoding' => 'Hex',
  'digestrealm-password-enc-algorithm' => 'SHA-256',
  'digest-algorithm' => 'SHA-256'
}

 glassfish_auth_realm "#{realmname}" do
   target "#{payara_config}"
   realm_name "#{realmname}"
   jaas_context "jdbcRealm"
   properties props
   domain_name domain_name
   password_file "#{domains_dir}/#{domain_name}_admin_passwd"
   username username
   admin_port admin_port
   secure false
   classname "com.sun.enterprise.security.auth.realm.jdbc.JDBCRealm"
 end

glassfish_asadmin "set configs.config.#{payara_config}.cdi-service.enable-concurrent-deployment=true" do
  domain_name domain_name
  password_file "#{domains_dir}/#{domain_name}_admin_passwd"
  username username
  admin_port admin_port
  secure false
end

glassfish_asadmin "set configs.config.#{payara_config}.cdi-service.pre-loader-thread-pool-size=#{node['glassfish']['ejb_loader']['thread_pool_size']}" do
  domain_name domain_name
  password_file "#{domains_dir}/#{domain_name}_admin_passwd"
  username username
  admin_port admin_port
  secure false
end

# add new network listener for Hopsworks to listen on an internal port
glassfish_asadmin "create-protocol --securityenabled=true --target #{payara_config} https-internal" do
  domain_name domain_name
  password_file "#{domains_dir}/#{domain_name}_admin_passwd"
  username username
  admin_port admin_port
  secure false
  not_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd} list-protocols #{payara_config} | grep 'https-internal'"
end

glassfish_asadmin "create-http --default-virtual-server server --target #{payara_config} https-internal" do
  domain_name domain_name
  password_file "#{domains_dir}/#{domain_name}_admin_passwd"
  username username
  admin_port admin_port
  secure false
  not_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd} get #{payara_config}.network-config.protocols.protocol.https-internal.* | grep 'http.uri-encoding'"
end

glassfish_asadmin "create-network-listener --listenerport #{node['hopsworks']['internal']['port']} --threadpool http-thread-pool --target #{payara_config} --protocol https-internal https-int-list" do
  domain_name domain_name
  password_file "#{domains_dir}/#{domain_name}_admin_passwd"
  username username
  admin_port admin_port
  secure false
  not_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd} list-http-listeners #{payara_config} | grep 'https-int-list'"
end

glassfish_conf = {
  "#{payara_config}.security-service.default-realm" => 'kthfsrealm',
  # Jobs in Hopsworks use the Timer service
  "#{payara_config}.ejb-container.ejb-timer-service.timer-datasource" => 'jdbc/hopsworksTimers',
  "#{payara_config}.ejb-container.ejb-timer-service.property.reschedule-failed-timer" => node['glassfish']['reschedule_failed_timer'],
  "#{payara_config}.http-service.virtual-server.server.property.send-error_1" => "\"code=404 path=#{domains_dir}/#{domain_name}/docroot/index.html reason=Resource_not_found\"",
  # Enable/Disable HTTP listener
  "configs.config.#{payara_config}.network-config.network-listeners.network-listener.http-listener-1.enabled" => false,
  # Make sure the https listener is listening on the requested port
  "configs.config.#{payara_config}.network-config.network-listeners.network-listener.http-listener-2.port" => node['hopsworks']['https']['port'],
  "configs.config.#{payara_config}.network-config.protocols.protocol.http-listener-2.http.http2-enabled" => false,
  "configs.config.#{payara_config}.network-config.protocols.protocol.https-internal.http.http2-enabled" => false,
  # Disable X-Powered-By and server headers
  "configs.config.#{payara_config}.network-config.protocols.protocol.http-listener-2.http.server-header" => false,
  "configs.config.#{payara_config}.network-config.protocols.protocol.http-listener-2.http.xpowered-by" => false,
  # Disable SSL3
  "#{payara_config}.network-config.protocols.protocol.http-listener-2.ssl.ssl3-enabled" => false,
  "#{payara_config}.network-config.protocols.protocol.sec-admin-listener.ssl.ssl3-enabled" => false,
  "#{payara_config}.network-config.protocols.protocol.https-internal.ssl.ssl3-enabled" => false,
  "#{payara_config}.admin-service.jmx-connector.system.ssl.ssl3-enabled" => false,
  "#{payara_config}.iiop-service.iiop-listener.SSL.ssl.ssl3-enabled" => false,
  "#{payara_config}.iiop-service.iiop-listener.SSL_MUTUALAUTH.ssl.ssl3-enabled" => false,
  # HTTP-2
  "configs.config.#{payara_config}.network-config.protocols.protocol.http-listener-2.http.http2-push-enabled" => true,
  # Disable TLS 1.0
  "#{payara_config}.network-config.protocols.protocol.http-listener-2.ssl.tls-enabled" => false,
  "#{payara_config}.network-config.protocols.protocol.sec-admin-listener.ssl.tls-enabled" => false,
  "#{payara_config}.network-config.protocols.protocol.https-internal.ssl.tls-enabled" => false,
  "#{payara_config}.admin-service.jmx-connector.system.ssl.tls-enabled" => false,
  "#{payara_config}.iiop-service.iiop-listener.SSL.ssl.tls-enabled" => false,
  "#{payara_config}.iiop-service.iiop-listener.SSL_MUTUALAUTH.ssl.tls-enabled" => false,
  # Restrict ciphersuite
  "configs.config.#{payara_config}.network-config.protocols.protocol.http-listener-2.ssl.ssl3-tls-ciphers" => node['glassfish']['ciphersuite'],
  "configs.config.#{payara_config}.network-config.protocols.protocol.sec-admin-listener.ssl.ssl3-tls-ciphers" => node['glassfish']['ciphersuite'],
  "configs.config.#{payara_config}.network-config.protocols.protocol.https-internal.ssl.ssl3-tls-ciphers" => node['glassfish']['ciphersuite'],
  "#{payara_config}.admin-service.jmx-connector.system.ssl.ssl3-tls-ciphers" => node['glassfish']['ciphersuite'],
  "#{payara_config}.iiop-service.iiop-listener.SSL.ssl.ssl3-tls-ciphers" => node['glassfish']['ciphersuite'],
  "#{payara_config}.iiop-service.iiop-listener.SSL_MUTUALAUTH.ssl.ssl3-tls-ciphers" => node['glassfish']['ciphersuite'],
  # Set correct thread-priority for the executor services - required during updates
  "resources.managed-executor-service.concurrent\/hopsExecutorService.thread-priority" => 10,
  "resources.managed-thread-factory.concurrent\/hopsThreadFactory.thread-priority" => 10,
  "resources.managed-executor-service.concurrent\/condaExecutorService.thread-priority" => 9,
  "resources.managed-executor-service.concurrent\/jupyterExecutorService.thread-priority" => 8,
  # Enable Single Sign on
  "configs.config.#{payara_config}.http-service.virtual-server.server.sso-enabled" => true,
  "configs.config.#{payara_config}.http-service.virtual-server.server.sso-cookie-http-only" => true,
  # Allow following symlinks from docroot
  "#{payara_config}.http-service.virtual-server.server.property.allowLinking" => true,
  "#{payara_config}.network-config.protocols.protocol.http-listener-2.http.timeout-seconds" => node['glassfish']['http']['keep_alive_timeout'],
  "#{payara_config}.network-config.protocols.protocol.http-listener-1.http.timeout-seconds" => node['glassfish']['http']['keep_alive_timeout'],
  "#{payara_config}.network-config.protocols.protocol.https-internal.http.timeout-seconds" => node['glassfish']['http']['keep_alive_timeout'],
  "resources.jdbc-connection-pool.hopsworksPool.property.User" => node['hopsworks']['mysql']['user'],
  "resources.jdbc-connection-pool.hopsworksPool.property.Password" => node['hopsworks']['mysql']['password'],
  "resources.jdbc-connection-pool.hopsworksPool.property.useSSL" => 'false',
  "resources.jdbc-connection-pool.hopsworksPool.property.allowPublicKeyRetrieval" => 'true',
  "resources.jdbc-connection-pool.ejbTimerPool.property.User" => node['hopsworks']['mysql']['user'],
  "resources.jdbc-connection-pool.ejbTimerPool.property.Password" => node['hopsworks']['mysql']['password'],
  "resources.jdbc-connection-pool.ejbTimerPool.property.useSSL" => 'false',
  "resources.jdbc-connection-pool.ejbTimerPool.property.allowPublicKeyRetrieval" => 'true',
  "#{payara_config}.network-config.protocols.protocol.https-internal.ssl.cert-nickname" => 'internal',
  # The timeout, in seconds, for requests. A value of -1 will disable it.
  "#{payara_config}.network-config.protocols.protocol.http-listener-2.http.request-timeout-seconds" => node['glassfish']['http']['request-timeout-seconds'],
  "#{payara_config}.network-config.protocols.protocol.http-listener-1.http.request-timeout-seconds" => node['glassfish']['http']['request-timeout-seconds']
}

glassfish_conf.each do |property, value|
  glassfish_asadmin "set #{property}=#{value}" do
   domain_name domain_name
   password_file "#{domains_dir}/#{domain_name}_admin_passwd"
   username username
   admin_port admin_port
   secure false
  end
end

glassfish_asadmin "create-managed-executor-service --target #{payara_config} --enabled=true --longrunningtasks=true --corepoolsize=50 --maximumpoolsize=400 --keepaliveseconds=60 --taskqueuecapacity=20000 concurrent/condaExecutorService" do
  domain_name domain_name
  password_file "#{domains_dir}/#{domain_name}_admin_passwd"
  username username
  admin_port admin_port
  secure false
 not_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd} list-managed-executor-services #{payara_config} | grep 'conda'"
end

glassfish_asadmin "create-managed-executor-service --target #{payara_config} --enabled=true --longrunningtasks=true --corepoolsize=10 --maximumpoolsize=200 --keepaliveseconds=60 --taskqueuecapacity=10000 concurrent/kagentExecutorService" do
  domain_name domain_name
  password_file "#{domains_dir}/#{domain_name}_admin_passwd"
  username username
  admin_port admin_port
  secure false
 not_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd}  list-managed-executor-services #{payara_config} | grep 'kagent'"
end

glassfish_asadmin "create-managed-executor-service --target #{payara_config} --enabled=true --threadpriority #{node['hopsworks']['managed_executor_pools']['jupyter']['threadpriority']} --longrunningtasks=true --corepoolsize #{node['hopsworks']['managed_executor_pools']['jupyter']['corepoolsize']} --maximumpoolsize #{node['hopsworks']['managed_executor_pools']['jupyter']['maximumpoolsize']} --taskqueuecapacity #{node['hopsworks']['managed_executor_pools']['jupyter']['taskqueuecapacity']} --description \"Hopsworks Jupyter Executor Service\" concurrent/jupyterExecutorService" do
  domain_name domain_name
  password_file "#{domains_dir}/#{domain_name}_admin_passwd"
  username username
  admin_port admin_port
  secure false
  not_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd} list-managed-executor-services #{payara_config} | grep 'concurrent/jupyterExecutorService$'"
end

# Enable JMX metrics
# https://glassfish.org/docs/5.1.0/administration-guide/monitoring.html
glassfish_asadmin "set-monitoring-configuration --target #{payara_config} --enabled=true --mbeansenabled=true --amxenabled=true --jmxlogfrequency=15 --jmxlogfrequencyunit=SECONDS --dynamic=true" do
  domain_name domain_name
  password_file "#{domains_dir}/#{domain_name}_admin_passwd"
  username username
  admin_port admin_port
  secure false
end

# Enable Rest metrics
# --securityenabled=true Configured file realm com.sun.enterprise.security.auth.realm.jdbc.JDBCRealm is not supported.
glassfish_asadmin "set-metrics-configuration --target #{payara_config} --enabled=true --dynamic=true" do
  domain_name domain_name
  password_file "#{domains_dir}/#{domain_name}_admin_passwd"
  username username
  admin_port admin_port
  secure false
end

glassfish_asadmin "set-monitoring-level --target #{payara_config} --module=jvm,connector-service,connector-connection-pool,jdbc-connection-pool,web-services-container,thread-pool,http-service,security,jersey,transaction-service,jpa,web-container --level=HIGH,HIGH,HIGH,HIGH,HIGH,HIGH,HIGH,HIGH,HIGH,HIGH,HIGH,HIGH" do
  domain_name domain_name
  password_file "#{domains_dir}/#{domain_name}_admin_passwd"
  username username
  admin_port admin_port
  secure false
end

if node['hopsworks']['http_logs']['enabled'].eql? "true"
  http_logging_conf = {
    # Enable http logging
    "#{payara_config}.http-service.access-logging-enabled" => 'true',
    # If you change the suffix, you should also change dump_web_logs_to_hdfs.sh.erb file
    # ':' is not a legal filename character in HDFS, thus '_'
    "#{payara_config}.http-service.access-log.rotation-suffix" => 'yyyy-MM-dd-kk_mm',
    "#{payara_config}.http-service.access-log.max-history-files" => '10',
    "#{payara_config}.http-service.access-log.buffer-size-bytes" => '32768',
    "#{payara_config}.http-service.access-log.write-interval-seconds" => '120',
    "#{payara_config}.http-service.access-log.rotation-interval-in-minutes" => "1400"
  }

  http_logging_conf.each do |property, value|
    glassfish_asadmin "set #{property}=#{value}" do
      domain_name domain_name
      password_file "#{domains_dir}/#{domain_name}_admin_passwd"
      username username
      admin_port admin_port
      secure false
    end
  end
end

if current_version.eql?("") == false
#
# undeploy previous version
#

  glassfish_deployable "hopsworks-ear" do
    component_name "hopsworks-ear:#{node['hopsworks']['current_version']}"
    target "#{payara_config}"
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
    component_name "hopsworks-web:#{node['hopsworks']['version']}"
    target "#{payara_config}"
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
    component_name "hopsworks-ca:#{node['hopsworks']['version']}"
    target "#{payara_config}"
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


glassfish_deployable "hopsworks-ear" do
  component_name "hopsworks-ear:#{node['hopsworks']['version']}"
  target "#{payara_config}"
  url node['hopsworks']['ear_url']
  auth_username node['install']['enterprise']['username']
  auth_password node['install']['enterprise']['password']
  version node['hopsworks']['version']
  domain_name domain_name
  password_file "#{domains_dir}/#{domain_name}_admin_passwd"
  username username
  admin_port admin_port
  secure false
  action :deploy
  async_replication false
  retries 1
  keep_state true
  enabled true
  not_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd}  list-applications --type ejb | grep -w \"hopsworks-ear:#{node['hopsworks']['version']}\""
end

glassfish_deployable "hopsworks" do
  component_name "hopsworks-web:#{node['hopsworks']['version']}"
  target "#{payara_config}"
  url node['hopsworks']['war_url']
  auth_username node['install']['enterprise']['username']
  auth_password node['install']['enterprise']['password']
  version node['hopsworks']['version']
  context_root "/hopsworks"
  domain_name domain_name
  password_file "#{domains_dir}/#{domain_name}_admin_passwd"
  username username
  admin_port admin_port
  secure false
  action :deploy
  async_replication false
  retries 1
  keep_state true
  enabled true
  not_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd}  list-applications --type web | grep -w \"hopsworks-web:#{node['hopsworks']['version']}\""
end

glassfish_deployable "hopsworks-ca" do
  component_name "hopsworks-ca:#{node['hopsworks']['version']}"
  target "#{payara_config}"
  url node['hopsworks']['ca_url']
  auth_username node['install']['enterprise']['username']
  auth_password node['install']['enterprise']['password']
  version node['hopsworks']['version']
  context_root "/hopsworks-ca"
  domain_name domain_name
  password_file "#{domains_dir}/#{domain_name}_admin_passwd"
  username username
  admin_port admin_port
  secure false
  action :deploy
  async_replication false
  retries 1
  keep_state true
  enabled true
  not_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd}  list-applications --type ejb | grep -w \"hopsworks-ca:#{node['hopsworks']['version']}\""
end
